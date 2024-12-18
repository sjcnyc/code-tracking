#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Identity.DirectoryManagement, Microsoft.Graph.Applications, Microsoft.Graph.Groups, ActiveDirectory, AzFilesHybrid

<#
.SYNOPSIS
This script is used to deploy an Azure Virtual Desktop (AVD) environment using Microsoft Graph API.

.DESCRIPTION
The script performs the following tasks:
1. Creates Active Directory (AD) security groups for AVD.
2. Adds nested memberships to the AD security groups.
3. Adds default users to the AD security groups.
4. Creates a deployment resource group and tags in Azure.
5. Creates a storage account and tags in Azure.
6. Enables SMB multi-channel for the storage account.
7. Creates an Azure Files file share with a quota of 100GB.
8. Joins the storage account to AD for SMB authentication.
9. Adds the "Storage File Data SMB Share Contributor" role to the security group for access to the storage account.

.PARAMETER DistName
The name of the AVD distribution.

.PARAMETER GroupsOu
The distinguished name of the OU where the AD security groups will be created.

.PARAMETER ContribGroup
The name of the AD security group for AVD contributor users.

.PARAMETER DesktopGroup
The name of the AD security group for AVD full desktop users.

.PARAMETER CAGroup
The name of the AD security group for AVD conditional access users.

.PARAMETER Users
An array of default users to be added to the AD security group for AVD full desktop users.

.PARAMETER TenantID
The ID of the Azure AD tenant.

.PARAMETER SubscriptionID
The ID of the Azure subscription.

.PARAMETER TargetOu
The distinguished name of the OU where the AVD deployment will be created in AD.

.NOTES
File Name      : New-AvdDeployment-Graph.ps1
Author         : Sean Connealy
Prerequisite   : Microsoft.Graph PowerShell modules, AzFilesHybrid module
Requirements   : PowerShell 5.1 or later
               : This script needs to be run from a Tier-2 or Tier-1 jumpbox depending on the deployment scope
#>

#Modules
Import-Module ActiveDirectory
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Applications
Import-Module Microsoft.Graph.Groups
# https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.2.9/AzFilesHybrid.zip
Import-Module AzFilesHybrid

# AVD Distribution Name
$DistName = "WNSD" #

# Active Directory vars
$GroupsOu     = "OU=Groups,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
$ContribGroup = "AZ_AVD_$($DistName)_Contributor_Users"
$DesktopGroup = "AZ_AVD_$($DistName)_FullDesktop"
$CAGroup      = "AZ_AVD_ConditionalAcccess_Users"
$Users        = @("sconnea", "AIRA003")

# Azure vars
$Date           = Get-Date -f "MM/dd/yyyy"
$CreatedBy      = "sean.connealy@sonymusic.com"
$TenantID       = "f0aff3b7-91a5-4aae-af71-c63e1dda2049"
$SubscriptionID = "bcda95b7-72ae-40ce-8967-f83a6597d40a"  # EUS-AVD

# Create avd/fslogix AD security groups
$groups = @{
    $ContribGroup = "AVD $($DistName) FSLogix Users"
    $DesktopGroup = "AVD $($Distname) Full Desktop"
}

# Create avd security groups
$groups.GetEnumerator() | ForEach-Object {
    $nEWADGroupSplat = @{
        Name        = $_.key
        Description = $_.value
        GroupScope  = 'Global'
        Path        = $GroupsOu
    }

    New-ADGroup @nEWADGroupSplat
}

# Add nested memberships
Add-ADGroupMember -Identity $ContribGroup -Members $DesktopGroup
Add-ADGroupMember -Identity $CAGroup -Members $ContribGroup

# Add default users, Sean/Mani
Add-ADGroupMember -Identity $DesktopGroup -Members $Users

#########################################################################################################################
# Force Azure AD Connect sync using Microsoft Graph
#########################################################################################################################

# Connect to Microsoft Graph
Connect-MgGraph -TenantId $TenantID -Scopes "Directory.ReadWrite.All", "Group.ReadWrite.All", "Application.ReadWrite.All"

# Force directory sync
# Note: This requires appropriate permissions and the sync service to be running
$syncJob = Invoke-MgDirectorySync

# Wait for sync to complete (typically takes a few minutes)
Start-Sleep -Seconds 300

# Kim needs to create the OU in AD first
$TargetOu = "OU=$($DistName),OU=AzureVDI,OU=Workstations,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"

# Create deployment resource group and tags using Graph API
$ResourceGroupName = "RG-$($DistName)-P-EUS"

$resourceGroup = @{
    location = "eastus"
    tags = @{
        CreatedBy = $CreatedBy
        CreatedOn = $Date
    }
}

$graphUri = "https://management.azure.com/subscriptions/$SubscriptionID/resourcegroups/$($ResourceGroupName)?api-version=2021-04-01"
$token = Get-MgUserAuthenticationToken

Invoke-RestMethod -Uri $graphUri -Method Put -Body ($resourceGroup | ConvertTo-Json) -Headers @{
    Authorization = "Bearer $token"
    'Content-Type' = 'application/json'
}

# Create storage account and tags
$StorageAccountName = ("stsme$($DistName)").ToLower()

if ($StorageAccountName.length -lt 9) {
    $StorageAccountName = "$($StorageAccountName)$(( (1..3) | ForEach-Object { Get-Random -Minimum 0 -Maximum 9 } ) -join '')"
}

$storageAccount = @{
    location = "eastus"
    sku = @{
        name = "Premium_LRS"
    }
    kind = "FileStorage"
    properties = @{
        allowBlobPublicAccess = $false
        largeFileSharesState = "Enabled"
        minimumTlsVersion = "TLS1_2"
    }
    tags = @{
        CreatedBy = $CreatedBy
        CreatedOn = $Date
    }
}

$graphUri = "https://management.azure.com/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$($StorageAccountName)?api-version=2021-04-01"

Invoke-RestMethod -Uri $graphUri -Method Put -Body ($storageAccount | ConvertTo-Json -Depth 10) -Headers @{
    Authorization = "Bearer $token"
    'Content-Type' = 'application/json'
}

# Wait for storage account creation
Start-Sleep -Seconds 60

# Enable SMB multi-channel
$smbMultiChannel = @{
    properties = @{
        shareProperties = @{
            enabledProtocols = "SMB"
            smbSettings = @{
                multichannel = @{
                    enabled = $true
                }
            }
        }
    }
}

$graphUri = "https://management.azure.com/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName/fileServices/default?api-version=2021-04-01"

Invoke-RestMethod -Uri $graphUri -Method Patch -Body ($smbMultiChannel | ConvertTo-Json -Depth 10) -Headers @{
    Authorization = "Bearer $token"
    'Content-Type' = 'application/json'
}

# Create azure files file share
$ShareName = "$($DistName.ToLower())-userprofiles"

$fileShare = @{
    properties = @{
        enabledProtocols = "SMB"
        shareQuota = 100
    }
}

$graphUri = "https://management.azure.com/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName/fileServices/default/shares/$($ShareName)?api-version=2021-04-01"

Invoke-RestMethod -Uri $graphUri -Method Put -Body ($fileShare | ConvertTo-Json -Depth 10) -Headers @{
    Authorization = "Bearer $token"
    'Content-Type' = 'application/json'
}

# Join storage account to AD for SMB authentication
$JoinAzStorageAccoutnForAuth = @{
    ResourceGroupName = $ResourceGroupName
    StorageAccountName = $StorageAccountName
    DomainAccountType = "ComputerAccount"
    OrganizationalUnitDistinguishedName = $TargetOu
}

Join-AzStorageAccountForAuth @JoinAzStorageAccoutnForAuth

# Get the security group id using Graph API
$group = Get-MgGroup -Filter "displayName eq '$ContribGroup'"

# Add "Storage File Data SMB Share Contributor" role to security group for access to storage account
$roleAssignment = @{
    properties = @{
        roleDefinitionId = "/subscriptions/$SubscriptionID/providers/Microsoft.Authorization/roleDefinitions/0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb" # Storage File Data SMB Share Contributor
        principalId = $group.Id
        principalType = "Group"
    }
}

$roleAssignmentGuid = (New-Guid).Guid
$graphUri = "https://management.azure.com/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName/providers/Microsoft.Authorization/roleAssignments/$($roleAssignmentGuid)?api-version=2020-04-01-preview"

Invoke-RestMethod -Uri $graphUri -Method Put -Body ($roleAssignment | ConvertTo-Json -Depth 10) -Headers @{
    Authorization = "Bearer $token"
    'Content-Type' = 'application/json'
}

Write-Host "AVD deployment completed successfully!"

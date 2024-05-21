<#
.SYNOPSIS
This script is used to deploy an Azure Virtual Desktop (AVD) environment.

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
File Name      : New-AvdDeployment.ps1
Author         : Sean Connealy
Prerequisite   : Azure PowerShell module
Requirements   : PowerShell 5.1 or later
               : This script needs to be run from a Tier-2 or Tier-1 jumpbox depending on the deployment scope
#>

#Modules
Import-Module ActiveDirectory
Import-Module Az
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
# WAIT 20 MIN FOR AD SYNC TO SYNC AD GROUPS BEFORE PROCEEDING!
# TODO: Need to get Azure AD Connect module to force the sync to happen. This is a manual process for now.
#########################################################################################################################

# Kim needs to create the OU in AD first
$TargetOu = "OU=$($DistName),OU=AzureVDI,OU=Workstations,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"

# Connect to Azure
Connect-AzAccount -Tenant $TenantID -SubscriptionId $SubscriptionID

# Create deployment resource group and tags
$ResourceGroupName = "RG-$($DistName)-P-EUS"

$newAzResourceGroupSplat = @{
    Name     = $ResourceGroupName
    Location = "EastUS"
    Tag      = @{CreatedBy = $CreatedBy; CreatedOn = $Date }
}

New-AzResourceGroup @newAzResourceGroupSplat

# Create storage account and tags
$StorageAccountName = ("stsme$($DistName)").ToLower()

if ($StorageAccountName.length -lt 9) {
    $StorageAccountName = "$($StorageAccountName)$(( (1..3) | ForEach-Object { Get-Random -Minimum 0 -Maximum 9 } ) -join '')"
}

$newAzStorageAccountSplat = @{
    ResourceGroupName     = $ResourceGroupName
    Name                  = $StorageAccountName
    Location              = "eastus"
    SkuName               = "Premium_LRS"
    Kind                  = 'FileStorage'
    AllowBlobPublicAccess = $false
    EnableLargeFileShare  = $true
    MinimumTlsVersion     = "TLS1_2"
    Tag                   = @{CreatedBy = $CreatedBy; CreatedOn = $Date }
}

New-AzStorageAccount @newAzStorageAccountSplat

# Get storage account
$StorageAccountName = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName

# Enable SMB multi-channel
Update-AzStorageFileServiceProperty -StorageAccount $storageAccountName -EnableSmbMultichannel $true

# Create azure files file share
$ShareName = "$($DistName.ToLower())-userprofiles"

# Set quota to 100GB
New-AzRmStorageShare -StorageAccount $StorageAccountName -Name $ShareName -EnabledProtocol SMB -QuotaGiB 100

# Join storage account to AD for SMB authentication
$JoinAzStorageAccoutnForAuth = @{
  ResourceGroupName                   = $ResourceGroupName
  StorageAccountName                  = $StorageAccountName.StorageAccountName
  DomainAccountType                   = "ComputerAccount"
  OrganizationalUnitDistinguishedName = $TargetOu
}

Join-AzStorageAccountForAuth @JoinAzStorageAccoutnForAuth

# Get the security group id for the contributor group
$GroupID = (Get-AzADGroup -DisplayName $ContribGroup).id

# Add "Storage File Data SMB Share Contributor" role to security group for access to storage account
# TODO: wait for ad sync to sync security groups to azure ad 20 min :(
$newAzRoleAssignmentSplat = @{
    ObjectId           = $GroupID
    RoleDefinitionName = "Storage File Data SMB Share Contributor"
    Scope              = "/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.Storage/storageAccounts/$($StorageAccountName.StorageAccountName)"
}

New-AzRoleAssignment @newAzRoleAssignmentSplat

# We are done.
# TODO: Finish refactor in Bicep  Lot's of moving parts, and Infosec blocks.  Will probably never be fully automated. :(
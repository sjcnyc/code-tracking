# AVD Distribution Name
$DistName = "RDC"

# Active Directory process
$GroupsOu = "OU=Groups,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
$ContribGroup = "AZ_AVD_$($DistName)_Contributor_Users"
$DesktopGroup = "AZ_AVD_$($DistName)_FullDesktop"
$CAGroup = "AZ_AVD_ConditionalAcccess_Users"
$Users = @("sconnea","NGOM002")

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

    NEW-ADGroup @nEWADGroupSplat
}

# Add nested memberships
Add-ADGroupMember -Identity $ContribGroup -Members $DesktopGroup
Add-ADGroupMember -Identity $CAGroup -Members $ContribGroup

# Add default users, sean/mike
Add-ADGroupMember -Identity $DesktopGroup -Members $Users

# WAIT 20 MIN FOR AD SYNC TO SYN AD GROUPS BEFORE PROCEEDING ##########################################################

# Azure Process
Import-Module -Name AzFilesHybrid 

# Azure vars
$Date           = Get-Date -f "MM/dd/yyyy"
$CreatedBy      = "sean.connealy@sonymusic.com"
$TenantID       = "f0aff3b7-91a5-4aae-af71-c63e1dda2049"
$SubscriptionID = "bcda95b7-72ae-40ce-8967-f83a6597d40a"
# Kim needs to create the OU in AD first
$TargetOu       = "OU=$($DistName),OU=AzureVDI,OU=Workstations,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"

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

# Get newly create storage account
$StorageAccountName = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName

# Enable smb multi channel
Update-AzStorageFileServiceProperty -StorageAccount $storageAccountName -EnableSmbMultichannel $true

# Azure Files share name
$ShareName = "$($DistName.ToLower())-userprofiles"

# Create azure files file share, set quota to 100gig
New-AzRmStorageShare -StorageAccount $StorageAccountName -Name $ShareName -EnabledProtocol SMB -QuotaGiB 100

# Join storage account to ad for smb auth
$JoinAzStorageAccoutnForAuth = @{
  ResourceGroupName                   = $ResourceGroupName
  StorageAccountName                  = $StorageAccountName.StorageAccountName
  DomainAccountType                   = "ComputerAccount"
  OrganizationalUnitDistinguishedName = $TargetOu
}

Join-AzStorageAccountForAuth @JoinAzStorageAccoutnForAuth

# Get ID for "AVD $($DistName) FSLogix Users" AD group
$GroupID = (Get-AzADGroup -DisplayName $ContribGroup).id

# Add "Storage File Data SMB Share Contributor" role to security group for access to storage account
# TODO: wait for ad sync to sync security groups to azure ad 20 min :(
$newAzRoleAssignmentSplat = @{
    ObjectId           = $GroupID
    RoleDefinitionName = "Storage File Data SMB Share Contributor"
    Scope              = "/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.Storage/storageAccounts/$($StorageAccountName.StorageAccountName)"
}

New-AzRoleAssignment @newAzRoleAssignmentSplat

# We are done.  Sheesh this needs to be refactored
# TODO: Refactor in Bicep manybe.  Lot's of moving parts.
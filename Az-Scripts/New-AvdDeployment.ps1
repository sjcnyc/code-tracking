Import-Module -Name AzFilesHybrid

$DistName = "GRP"
$GroupsOu = "OU=Groups,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
$ContribGroup = "AZ_AVD_$($DistName)_Contributor_Users"
$DesktopGroup = "AZ_AVD_$($DistName)_FullDesktop"
$CAGroup = "AZ_AVD_ConditionalAcccess_Users"
$Users = @("sconnea","NGOM002")

$Date = Get-Date -f "MM/dd/yyyy"
$CreatedBy = "sean.connealy@sonymusic.com"
$TenantID = "f0aff3b7-91a5-4aae-af71-c63e1dda2049"
$SubscriptionID = "bcda95b7-72ae-40ce-8967-f83a6597d40a"
$TargetOu = "OU=GRP,OU=AzureVDI,OU=Workstations,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"

Connect-AzAccount -Tenant $TenantID -SubscriptionId $SubscriptionID

$groups = @{
    $ContribGroup = "AVD $($DistName) FSLogix Users"
    $DesktopGroup = "AVD $($Distname) Full Desktop"
}

# create avd security groups
$groups.GetEnumerator() | ForEach-Object {
    $nEWADGroupSplat = @{
        Name        = $_.key
        Description = $_.value
        GroupScope  = 'Global'
        Path        = $GroupsOu
    }

    NEW-ADGroup @nEWADGroupSplat
}

# add nested memberships
Add-ADGroupMember -Identity $ContribGroup -Members $DesktopGroup
Add-ADGroupMember -Identity $CAGroup -Members $ContribGroup

# add default users, sean/mike
Add-ADGroupMember -Identity $DesktopGroup -Members $Users

# create deployment resource group and tags
$ResourceGroupName = "RG-$($DistName)-P-EUS"

$newAzResourceGroupSplat = @{
    Name     = $ResourceGroupName
    Location = "EastUS"
    Tag      = @{CreatedBy = $CreatedBy; CreatedOn = $Date }
}

New-AzResourceGroup @newAzResourceGroupSplat

# create storage account and tags
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

$StorageAccountName = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName

# enable smb multi channel
Update-AzStorageFileServiceProperty -StorageAccount $storageAccountName -EnableSmbMultichannel $true

$ShareName = "$($DistName.ToLower())-userprofiles"

# create azure files file share, set quota to 100gig
New-AzRmStorageShare -StorageAccount $StorageAccountName -Name $ShareName -EnabledProtocol SMB -QuotaGiB 100

# joinstorage account to ad for smb auth
$JoinAzStorageAccoutnForAuth = @{
  ResourceGroupName                   = $ResourceGroupName
  StorageAccountName                  = $StorageAccountName.StorageAccountName
  DomainAccountType                   = "ComputerAccount"
  OrganizationalUnitDistinguishedName = $TargetOu
}

Join-AzStorageAccountForAuth @JoinAzStorageAccoutnForAuth

$GroupID = (Get-AzADGroup -DisplayName $ContribGroup).id

# add "Storage File Data SMB Share Contributor" role to security group for access to storage account
# TODO: wait for ad sync to sync security groups to azure ad 20 min :(
$newAzRoleAssignmentSplat = @{
    ObjectId           = $GroupID
    RoleDefinitionName = "Storage File Data SMB Share Contributor"
    Scope              = "/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.Storage/storageAccounts/$($StorageAccountName.StorageAccountName)"
}

New-AzRoleAssignment @newAzRoleAssignmentSplat
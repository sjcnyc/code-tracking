Import-Module -Name AzFilesHybrid

$distName = "GRP"
$ou = "OU=Groups,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
$targetOu = "OU=DSC,OU=AzureVDI,OU=Workstations,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
$date = Get-Date -f "MM/dd/yyyy"
$createdBy = "sean.connealy@sonymusic.com"
$SubscriptionId = "bcda95b7-72ae-40ce-8967-f83a6597d40a"

Connect-AzAccount -UseDeviceAuthentication
Select-AzSubscription -SubscriptionId $SubscriptionId

$groups = @{
    "AZ_AVD_$($distName)_Contributor_Users" = "AVD $($distName) FSLogix Users"
    "AZ_AVD_$($distName)_FullDesktop" = "AVD $($distname) Full Desktop"
}

$groups.GetEnumerator() | ForEach-Object {
    $nEWADGroupSplat = @{
        Name        = $_.key
        Description = $_.value
        GroupScope  = 'Global'
        Path        = $ou
    }

    NEW-ADGroup @nEWADGroupSplat
}

Add-ADGroupMember -Identity "AZ_AVD_$($distName)_Contributor_Users" -Members "AZ_AVD_$($distName)_FullDesktop"
Add-ADGroupMember -Identity "AZ_AVD_ConditionalAcccess_Users" -Members "AZ_AVD_$($distName)_Contributor_Users"

$users = @("sconnea","NGOM002")

Add-ADGroupMember -Identity "AZ_AVD_$($distName)_FullDesktop" -Members $users

$resourceGroupName = "RG-$($distName)-P-EUS"

$newAzResourceGroupSplat = @{
    Name     = $resourceGroupName
    Location = "EastUS"
    Tag      = @{CreatedBy = $createdBy; CreatedOn = $date }
}

New-AzResourceGroup @newAzResourceGroupSplat


$storageAccount = ("stsme$($distName)").ToLower()

if ($storageAccount.length -lt 9) {
    $storageAccount = "$($storageAccount)$(( (1..3) | ForEach-Object { Get-Random -Minimum 0 -Maximum 9 } ) -join '')"
}


$newAzStorageAccountSplat = @{
    ResourceGroupName     = $resourceGroupName
    Name                  = $storageAccount
    Location              = "eastus"
    SkuName               = "Premium_LRS"
    Kind                  = 'FileStorage'
    AllowBlobPublicAccess = $false
    EnableLargeFileShare  = $true
    Tag                   = @{CreatedBy = $createdBy; CreatedOn = $date }
}

New-AzStorageAccount @newAzStorageAccountSplat

$storageAccountName = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccount

Update-AzStorageFileServiceProperty -StorageAccount $storageAccountName -EnableSmbMultichannel $true

$shareName = "$($distName.ToLower())-userprofiles"

New-AzRmStorageShare -StorageAccount $storageAccountName -Name $shareName -EnabledProtocol SMB -QuotaGiB 100

$JoinAzStorageAccoutnForAuth = @{
  ResourceGroupName                   = $resourceGroupName
  StorageAccountName                  = $storageAccountName
  DomainAccountType                   = "ComputerAccount"
  OrganizationalUnitDistinguishedName = $targetOu
}

Join-AzStorageAccountForAuth @JoinAzStorageAccoutnForAuth
# download AzFilesHybrid module and copy to t1/t2 jumpbox
https://github.com/Azure-Samples/azure-files-samples/releases

#Run ps as admin
#Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
.\CopyToPSPath.ps1

#Import AzFilesHybrid module
Import-Module -Name AzFilesHybrid

#Login with an Azure AD credential that has either storage account owner or contributer Azure role assignment
Connect-AzAccount -UseDeviceAuthentication

#Define parameters
$SubscriptionId = "bcda95b7-72ae-40ce-8967-f83a6597d40a"
$ResourceGroupName = "RG-WVD-ADMT1-P-EUS"
$StorageAccountName = "stwvdfslxadmt1"
$targetOu = "OU=JMP,OU=GBL,OU=USA,OU=NA,OU=SRV,OU=Tier-1,DC=me,DC=sonymusic,DC=com"

#Select the target subscription for the current session
Select-AzSubscription -SubscriptionId $SubscriptionId

<#
Register the target storage account with your active directory environment under the target OU (for example: specify the OU with Name as "UserAccounts" or DistinguishedName as "OU=UserAccounts,DC=CONTOSO,DC=COM").
You can use to this PowerShell cmdlet: Get-ADOrganizationalUnit to find the Name and DistinguishedName of your target OU. If you are using the OU Name, specify it with -OrganizationalUnitName as shown below. If you are using the OU DistinguishedName, you can set it with -OrganizationalUnitDistinguishedName. You can choose to provide one of the two names to specify the target OU.
You can choose to create the identity that represents the storage account as either a Service Logon Account or Computer Account (default parameter value), depends on the AD permission you have and preference.
Run Get-Help Join-AzStorageAccountForAuth for more details on this cmdlet.
#>

$JoinAzStorageAccoutnForAuth = @{
  ResourceGroupName                   = $ResourceGroupName
  StorageAccountName                  = $StorageAccountName
  DomainAccountType                   = "ComputerAccount"
  OrganizationalUnitDistinguishedName = $targetOu
}
Join-AzStorageAccountForAuth @JoinAzStorageAccoutnForAuth

# Run the command below if you want to enable AES 256 authentication. If you plan to use RC4, you can skip this step.
# Update-AzStorageAccountAuthForAES256 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName

# Use Get-ADDomain to get domain information to manually enable domain services for storage account
$ADDomainInfo = Get-ADDomain | Select-Object Name, NetBIOSname, DNSRoot, ObjectGUID, DomainSID

# Get-ADComputer to get commputer name and sid of storage account computer object
$ADComputerInfo = Get-ADComputer $storageAccountName | Select-Object SID

# Set the feature flag on the target storage account and provide the required AD domain information
$SetAzStorageAccountSplat = @{
  ResourceGroupName                          = $ResourceGroupName
  Name                                       = $StorageAccountName
  EnableActiveDirectoryDomainServicesForFile = $true
  ActiveDirectoryDomainName                  = $ADDomainInfo.Name
  ActiveDirectoryNetBiosDomainName           = $ADDomainInfo.NetBIOSname
  ActiveDirectoryForestNam                   = $ADDomainInfo.DNSRoot
  ActiveDirectoryDomainGuid                  = $ADDomainInfo.ObjectGUID
  ActiveDirectoryDomainSid                   = $ADDomainInfo.DomainSID
  ActiveDirectoryAzureStorageSid             = $ADComputerInfo.SID
}
Set-AzStorageAccount @SetAzStorageAccountSplat

# Test if enabled.  Check storage account configuration to see if joined to domain
$GetAzStorageAccountSplat = @{
  ResourceGroupName = $ResourceGroupName
  Name              = $StorageAccountName
}
$storageAccount = Get-AzStorageAccount @GetAzStorageAccountSplat
# List the directory service of the selected service account
$storageAccount.AzureFilesIdentityBasedAuth.DirectoryServiceOptions
# List the directory domain information if the storage account has enabled AD DS authentication for file shares
$storageAccount.AzureFilesIdentityBasedAuth.ActiveDirectoryProperties

#Run the Debug-AzStorageAccountAuth cmdlet to conduct a set of basic checks on your AD configuration with the logged on AD user. This cmdlet is supported on AzFilesHybrid v0.1.2+ version. For more details on the checks performed in this cmdlet, see Azure Files Windows troubleshooting guide.
#Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose
#SPN: "cifs/your-storage-account-name-here.file.core.windows.net" Password: Kerberos key for your storage account.


#set time zones on session hosts.  should be done via gpo in production
$tz = Get-TimeZone -ListAvailable | Out-GridView -OutputMode Single
Set-TimeZone -Id $tz.Id
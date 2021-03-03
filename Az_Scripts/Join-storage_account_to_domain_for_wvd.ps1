# download AzFilesHybrid module and copy to t1 jmpbox
https://github.com/Azure-Samples/azure-files-samples/releases


#Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
#.\CopyToPSPath.ps1 

#Import AzFilesHybrid module
Import-Module -Name AzFilesHybrid

#Login with an Azure AD credential that has either storage account owner or contributer Azure role assignment
Connect-AzAccount 

#Define parameters
$SubscriptionId = "bcda95b7-72ae-40ce-8967-f83a6597d40a"
$ResourceGroupName = "WVD-ADMIN-P-EUS"
$StorageAccountName = "stfxlogixwpf"

#Select the target subscription for the current session
Select-AzSubscription -SubscriptionId $SubscriptionId 

# Register the target storage account with your active directory environment under the target OU (for example: specify the OU with Name as "UserAccounts" or DistinguishedName as "OU=UserAccounts,DC=CONTOSO,DC=COM"). 
# You can use to this PowerShell cmdlet: Get-ADOrganizationalUnit to find the Name and DistinguishedName of your target OU. If you are using the OU Name, specify it with -OrganizationalUnitName as shown below. If you are using the OU DistinguishedName, you can set it with -OrganizationalUnitDistinguishedName. You can choose to provide one of the two names to specify the target OU.
# You can choose to create the identity that represents the storage account as either a Service Logon Account or Computer Account (default parameter value), depends on the AD permission you have and preference.
# Run Get-Help Join-AzStorageAccountForAuth for more details on this cmdlet.

Join-AzStorageAccountForAuth `
  -ResourceGroupName $ResourceGroupName `
  -StorageAccountName $StorageAccountName `
  -DomainAccountType ComputerAccount <# Default is set as ComputerAccount #> `
  -OrganizationalUnitDistinguishedName "OU=Okta,OU=GBL,OU=USA,OU=NA,OU=SRV,OU=Tier-1,DC=me,DC=sonymusic,DC=com" <# If you don't provide the OU name as an input parameter, the AD identity that represents the storage account is created under the root directory. #> `
  #-EncryptionType "<AES256/RC4/AES256,RC4>" <# Specify the encryption agorithm used for Kerberos authentication. Default is configured as "'RC4','AES256'" which supports both 'RC4' and 'AES256' encryption. #>

#Run the command below if you want to enable AES 256 authentication. If you plan to use RC4, you can skip this step.
Update-AzStorageAccountAuthForAES256 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName

#You can run the Debug-AzStorageAccountAuth cmdlet to conduct a set of basic checks on your AD configuration with the logged on AD user. This cmdlet is supported on AzFilesHybrid v0.1.2+ version. For more details on the checks performed in this cmdlet, see Azure Files Windows troubleshooting guide.
Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose



SPN: "cifs/your-storage-account-name-here.file.core.windows.net" Password: Kerberos key for your storage account.


$storageaccount = Get-AzStorageAccount `
  -ResourceGroupName $ResourceGroupName `
  -Name $StorageAccountName

# List the directory service of the selected service account
$storageAccount.AzureFilesIdentityBasedAuth.DirectoryServiceOptions

# List the directory domain information if the storage account has enabled AD DS authentication for file shares
$storageAccount.AzureFilesIdentityBasedAuth.ActiveDirectoryProperties


# use Get-ADDomain to get domain information to manually enable domain services for storage account
Get-ADDomain
# Get-ADCompauter to get commputer name and sid of storage account computer object

# Set the feature flag on the target storage account and provide the required AD domain information
Set-AzStorageAccount `
  -ResourceGroupName "WVD-ADMIN-P-EUS" `
  -Name "stfxlogixwpf" `
  -EnableActiveDirectoryDomainServicesForFile $true `
  -ActiveDirectoryDomainName "me" `
  -ActiveDirectoryNetBiosDomainName "ME" `
  -ActiveDirectoryForestName "me.sonymusic.com" `
  -ActiveDirectoryDomainGuid "0e619ded-0d6b-41c1-84e0-2cfa857f6d52" `
  -ActiveDirectoryDomainsid "S-1-5-21-804046446-3026172632-3320083432" `
  -ActiveDirectoryAzureStorageSid "S-1-5-21-804046446-3026172632-3320083432-106771"

# test if enabled.  can aso check storage account configuration to see if joined to domain
# Get the target storage account
$storageaccount = Get-AzStorageAccount `
  -ResourceGroupName "<your-resource-group-name-here>" `
  -Name "<your-storage-account-name-here>"

# List the directory service of the selected service account
$storageAccount.AzureFilesIdentityBasedAuth.DirectoryServiceOptions

# List the directory domain information if the storage account has enabled AD DS authentication for file shares
$storageAccount.AzureFilesIdentityBasedAuth.ActiveDirectoryProperties


#set time zones on session hosts.  should be done via gpo in production
$tz = Get-TimeZone -ListAvailable | Out-GridView -OutputMode Single
Set-TimeZone -Id $tz.Id
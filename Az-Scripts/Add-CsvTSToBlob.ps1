<#
.SYNOPSIS
This script connects to Azure using the Az module, retrieves an access token for Microsoft Graph API, and uploads CSV files to an Azure Blob Storage container.

.DESCRIPTION
The script performs the following steps:
1. Connects to Azure using the Connect-AzAccount cmdlet.
2. Retrieves an access token for Microsoft Graph API using the Get-AzAccessToken cmdlet.
3. Connects to Microsoft Graph API using the Connect-MgGraph cmdlet.
4. Defines the root directory, date, key vault name, and container name variables.
5. Retrieves a SAS token from Azure Key Vault using the Get-AzKeyVaultSecret cmdlet.
6. Parses the SAS token to extract the storage account name, container name, and SAS token.
7. Retrieves a list of Azure AD group members using the Get-MgGroupMemberAsUser cmdlet.
8. Exports the group members' display names and user principal names to CSV files.
9. Creates a storage context using the New-AzStorageContext cmdlet.
10. Uploads the CSV files to the Azure Blob Storage container using the Set-AzStorageBlobContent cmdlet.
11. Removes the uploaded CSV files from the local directory.

.PARAMETER None
This script does not accept any parameters.

.EXAMPLE
.\Add-CsvTSToBlob.ps1
Runs the script to connect to Azure, retrieve an access token, and upload CSV files to Azure Blob Storage.

.NOTES
- This script requires the Az and Graph modules to be installed.
- You need to have the necessary permissions to access Azure resources and Azure Key Vault.
#>

Connect-AzAccount

# Retrieve an access token for Microsoft Graph API
$token = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com"

# Connect to Microsoft Graph API using the access token
Connect-MgGraph -AccessToken ($token.Token | ConvertTo-SecureString -AsPlainText -Force) -NoWelcome

# Define variables
$RootDirectory = "c:\temp\AzCopy"
$Date          = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmss")
$KeyVaultName  = "KV-INFRA-P-EUS"
$ContainerName = "stmaintest"

# Retrieve SAS token from Azure Key Vault
$SASToken = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ContainerName -AsPlainText

# Construct the destination SAS URL
$destinationSAS = "https://stmanitest.blob.core.windows.net/dropoff?$SASToken"
$uri = [System.Uri] $destinationSAS
$storageAccountName = $uri.DnsSafeHost.Split(".")[0]
$container = $uri.LocalPath.Substring(1)
$sasToken1 = $uri.Query -replace "\?", ""

# Define Azure AD groups and their corresponding object IDs
$AzGroups = @{
    "AZ_DG_All_Sony_Music_NON_Employees" = "8afcc0fd-967d-47c3-9dcd-91a8dfff5e5e"
    "AZ_DG_All_Sony_Music_Employees"     = "b21ec49b-925c-444c-8ff4-75f190ba8e41"
}

# Export group members' display names and user principal names to CSV files
$AZGroups.GetEnumerator() | ForEach-Object {
    $GroupSplat = @{
        GroupName = $_.key
        ObjectId  = $_.value
    }

    Get-MgGroupMemberAsUser -GroupId $GroupSplat.ObjectId -Property "displayName, userprincipalName, givenName, surName, mail" -ConsistencyLevel eventual -All |
        Select-Object displayName, userprincipalName, givenName, surName, mail |
        Export-Csv -Path "$($RootDirectory)\$($GroupSplat.GroupName)_Members_$($Date).csv" -NoTypeInformation
}

# Create a storage context using the storage account name and SAS token
$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasToken1

# Upload CSV files to Azure Blob Storage
Get-ChildItem -Path $RootDirectory -File -Filter *.csv | ForEach-Object {
    $fileToUpload = $_.FullName
    $blobName = $_.Name
    Set-AzStorageBlobContent -File $fileToUpload -Container $container -Context $storageContext -Force -Blob $blobName | Out-Null
    Start-Sleep -Seconds 2
    Remove-Item -Path $fileToUpload -Force
}
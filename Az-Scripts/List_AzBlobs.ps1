Import-Module Az
$azStorageAccountName = "sa01sftx3406815508"
$azStorageAccountKey = "6+KFw6fcjw9mhmExSbXrixZMuYz9kOkCAburdJKpmxhuy+ZVmSyeLce9WY8yj6+6nKCwoLqZbbhkfbI4zPKrLg=="
$azContainerName = "con01-sf-dropoff"
$azResourceGroupName = "rg-SalesForceTx-prod"

$connectionContext = (Get-AzStorageAccount -AccountName $azStorageAccountName).Context
# Get a list of containers in a storage account
Get-AzStorageContainer -Name $azStorageAccountName -Context $connectionContext | Select-Object Name
# Get a list of blobs in a container
Get-AzStorageBlob -Container $azContainerName -Context $connectionContext

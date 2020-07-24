Import-Module Az
$azStorageAccountName = "sa01sftx3406815508"
$azStorageAccountKey = "2u6z1WymVz3kYLZZa+xHsLdZSvDYQLXVMN/V27TMUgQe6XKE2bUYyVySBjvC5ps0XHo/nsqSRjufyScGVg7f4Q=="
$azContainerName = "con01-sf-dropoff"
$azResourceGroupName = "rg-SalesForceTx-prod"

$connectionContext = (Get-AzStorageAccount -ResourceGroupName $azResourceGroupName -AccountName $azStorageAccountName).Context
# Get a list of containers in a storage account
Get-AzStorageContainer -Name $azStorageAccountName -Context $connectionContext | Select-Object Name
# Get a list of blobs in a container
Get-AzStorageBlob -Container $azContainerName -Context $connectionContext

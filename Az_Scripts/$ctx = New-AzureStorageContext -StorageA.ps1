$ctx = New-AzureStorageContext -StorageAccountName "sa01sftx3406815508" -StorageAccountKey "2u6z1WymVz3kYLZZa+xHsLdZSvDYQLXVMN/V27TMUgQe6XKE2bUYyVySBjvC5ps0XHo/nsqSRjufyScGVg7f4Q=="

Get-AzureStorageContainer -Context $ctx



#Connection String

#"DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=sa01sftx3406815508;AccountKey=2u6z1WymVz3kYLZZa+xHsLdZSvDYQLXVMN/V27TMUgQe6XKE2bUYyVySBjvC5ps0XHo/nsqSRjufyScGVg7f4Q=="



#storage account

#sa01sftx3406815508



#Key

#2u6z1WymVz3kYLZZa+xHsLdZSvDYQLXVMN/V27TMUgQe6XKE2bUYyVySBjvC5ps0XHo/nsqSRjufyScGVg7f4Q==



#container

#con01-sf-dropoff

Connect-AzAccount -Subscription '90628b78-8a6d-4322-8d51-44974af1ad86' -Tenant 'f0aff3b7-91a5-4aae-af71-c63e1dda2049'

$azStorageAccountName = "sa01sftx3406815508"
$azContainerName = "con01-sf-dropoff"
$azResourceGroupName = "rg-SalesForceTx-prod"
$connectionContext = (Get-AzStorageAccount -ResourceGroupName $azResourceGroupName -AccountName $azStorageAccountName).Context

Get-AzStorageContainer -Name $azStorageAccountName -Context $connectionContext
$ConnectionString = "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=sa01sftx3406815508;AccountKey=2u6z1WymVz3kYLZZa+xHsLdZSvDYQLXVMN/V27TMUgQe6XKE2bUYyVySBjvC5ps0XHo/nsqSRjufyScGVg7f4Q=="
$Ctx = New-AzStorageContext -ConnectionString $ConnectionString



$ContainerName = "con01-sf-dropoff"

#Uploading File
$BlobName = "00283930_08032020_1413.xml"
$localFile = "D:\" + $BlobName

#Note the Force switch will overwrite if the file already exists in the Azure container
$setAzStorageBlobContentSplat = @{
    File = $localFile
    Container = $ContainerName
    Blob = $BlobName
    Context = $Ctx
    Force = $true
}

Set-AzStorageBlobContent @setAzStorageBlobContentSplat


#Download File
$BlobName = "Comps.csv"
$localTargetDirectory = "C:\Temp"

$getAzStorageBlobContentSplat = @{
    Blob = $BlobName
    Container = $ContainerName
    Destination = $localTargetDirectory
    Context = $ctx
}

Get-AzStorageBlobContent @getAzStorageBlobContentSplat

$getAzStorageBlobSplat = @{
    Container = $ContainerName
    Context = $Ctx
    IncludeDeleted = $true
}

Get-AzStorageBlob @getAzStorageBlobSplat





$startCopyAzureStorageBlobSplat = @{
    Context       = $SourceStorageContext
    SrcContainer  = $containerName
    SrcBlob       = $Blob.Name
    DestContext   = $DestStorageContext
    DestContainer = $containerName
    DestBlob      = $Blob.Name
}

Start-CopyAzureStorageBlob @startCopyAzureStorageBlobSplat


$invoice = '2020-10-26 00:00:00'
[datetime]::parseexact($invoice, 'yyyy-MM-dd HH:mm:ss', $null)

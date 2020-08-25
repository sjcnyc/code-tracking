$ConnectionString = "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=sa01sftx3406815508;AccountKey=2u6z1WymVz3kYLZZa+xHsLdZSvDYQLXVMN/V27TMUgQe6XKE2bUYyVySBjvC5ps0XHo/nsqSRjufyScGVg7f4Q=="
$Ctx = New-AzStorageContext -ConnectionString $ConnectionString

$ContainerName = "con01-sf-archive"

$getAzStorageBlobSplat = @{
  Container      = $ContainerName
  Context        = $Ctx
  IncludeDeleted = $false
}

$newblob = Get-AzStorageBlob @getAzStorageBlobSplat

[Xml]$TicketXML = $newBlob.ICloudBlob.DownloadText()

foreach ($xml in $TicketXML.userAction) {
  [pscustomobject]@{
    userID     = $xml.userID
    expiredate = $xml.expdate
    TicketNo   = $xml.ticketnumber
    refId      = $xml.refId
  }
}

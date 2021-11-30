Import-Module Az -RequiredVersion
$ConnectionString = "DefaultEndpointsProtocol=https;AccountName=sa01sftx3406815508;AccountKey=eMXdKI+AkS7c7Y1XJFmfs/EFJSWW8nhZKv4tnZs523ykC4Nn/iZug9yzlGhvLob6kPJKal5HZYC5CAMX9BYpKg==;EndpointSuffix=core.windows.net"
$SourceStorageContext = New-AzStorageContext -ConnectionString $ConnectionString

$ContainerName = "con01-sf-dropoff"
#$archiveContainer = "con01-sf-archive"


$Blobs = (Get-AzStorageBlob -Container $containerName -Context $SourceStorageContext) #.Where{ $_.ContentType -eq "application/xml" -and $_.name -like "00*"} #| Select-Object Name

$Blobs


foreach ($Blob in $Blobs) {

  $getAzStorageBlobContentSplat = @{
    Blob        = $Blob.Name
    Container   = $ContainerName
    Destination = "D:\Blobs"
    Context     = $SourceStorageContext
  }

  Get-AzStorageBlobContent @getAzStorageBlobContentSplat
}

$LocalBlobs = Get-ChildItem -Path D:\Blobs -File -Filter *.xml

$tickets =
foreach ($XMLFile in $LocalBlobs) {

  $TicketXML = [Xml] (Get-Content -Path "$($XMLFile.FullName)")

  $Aduser = (Get-ADUser -Filter "sAMAccountName -eq '$($TicketXML.userAction.userId)'" -Properties CanonicalName).CanonicalName

  [PSCustomObject]@{
    sAMAccountName = ($TicketXML.userAction).userId
    expdate        = [datetime]::parseexact((($TicketXML.userAction).expdate), 'yyyy-MM-dd HH:mm:ss', $null)
    ticketNo       = ($TicketXML.userAction).ticketnumber
    refId          = ($TicketXML.userAction).RefId
    canonicalName  = $Aduser
  }

  $expiresdate = [datetime]::parseexact((($TicketXML.userAction).expdate), 'yyyy-MM-dd HH:mm:ss', $null).ToString('MM/dd/yyyy')

  #Set-ADAccountExpiration -Identity $($TicketXML.userAction.userId) -DateTime $expiresdate -WhatIf

}

$tickets

$archiveContanier = "con01-sf-archive"

#Get-AzStorageBlobContent -Blob $BlobName -Container $ContainerName -Destination $localTargetDirectory -Context $SourceStorageContext

Get-AzStorageBlob -Container $archiveContanier -Context $SourceStorageContext -Blob $BlobName | Select-Object Name, BlobType, Length, ContentType, LastModified

#Write-Output $Blobs

#$Blobs = Get-AzureStorageBlob -Context $SourceStorageContext -Container $containerName



<#Do the copy of everything
foreach ($Blob in $Blobs) {
   Write-Output "Moving $Blob.Name"

   $startCopyAzureStorageBlobSplat = @{
    Context       = $SourceStorageContext
    SrcContainer  = $containerName
    SrcBlob       = $Blob.Name
    DestContext   = $DestStorageContext
    DestContainer = $containerName
    DestBlob      = $Blob.Name
}

Start-CopyAzureStorageBlob @startCopyAzureStorageBlobSplat
}

Get-AzureStorageContainer -Container container* | Remove-AzureStorageBlob -Blob "BlobName"
#>




# For errors Salesforce.Requests@sonymusic.com
# For success extend.account@sonymusic.com

# Add refID as the subject of extend.account@sonymusic.com success message E.g. Account access extended. Ref#{ref:00DS9jg5.500SCKwY8:ref}
# Add "Account not extended. Ticket# {Ticket # from file}" to Salesforce.Requests@sonymusic.com fail message


# email body can have error details


# testing "helpdesk.request@3-1oymgw3aeqp1ix69dacphk24ibeezn5cuefe6l1qhv039kfo4c.s-9jg5maa.s.case.sandbox.salesforce.com"

$EmailParams = @{
  #to = "sconnea@sonymusic.com"
  to         = "helpdesk.request@3-1oymgw3aeqp1ix69dacphk24ibeezn5cuefe6l1qhv039kfo4c.s-9jg5maa.s.case.sandbox.salesforce.com"
  from       = 'sconnea@sonymusic.com'
  subject    = "Account access extended. Ref#{ref:00DS9jg5.500SCKwY8:ref}"
  smtpserver = 'cmailsony.servicemail24.de'
  Body       = "Test email from runbook"
  BodyAsHTML = $true
}

  Send-MailMessage @EmailParams



#Uploading File
#$BlobName = "Comps.csv"
#$localFile = "D:\temp\" + $BlobName

#Note the Force switch will overwrite if the file already exists in the Azure container
#Set-AzStorageBlobContent -File $localFile -Container $archiveContainer -Blob $BlobName -Context $SourceStorageContext -Force
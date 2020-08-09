Import-Module Az
$ErrorActionPreference = "Continue"
$ADUser = $null
$LocalXMLPath = 'D:\Blobs'
$ConnectionString = "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=sa01sftx3406815508;AccountKey=2u6z1WymVz3kYLZZa+xHsLdZSvDYQLXVMN/V27TMUgQe6XKE2bUYyVySBjvC5ps0XHo/nsqSRjufyScGVg7f4Q=="
$SourceStorageContext = New-AzStorageContext -ConnectionString $ConnectionString
$SrcContainer = "con01-sf-dropoff"
$DestContainer = "con01-sf-archive"

$Blobs = Get-AzStorageBlob -Container $SrcContainer -Context $SourceStorageContext | Where-Object { $_.name -like "00*" }

foreach ($Blob in $Blobs) {

  $getAzStorageBlobContentSplat = @{
    Blob        = $Blob.Name
    Container   = $SrcContainer
    Destination = $LocalXMLPath
    Context     = $SourceStorageContext
  }

  Get-AzStorageBlobContent @getAzStorageBlobContentSplat -Force

  $startAzStorageBlobCopySplat = @{
    SrcBlob       = $Blob.Name
    Context       = $SourceStorageContext
    SrcContainer  = $SrcContainer
    DestContainer = $DestContainer
    DestBlob      = $Blob.Name
  }

  Start-AzStorageBlobCopy @startAzStorageBlobCopySplat
  Remove-AzStorageBlob -Context $SourceStorageContext -Container $DestContainer -Blob $Blob.Name

  $LocalXMLFiles = Get-ChildItem -Path D:\Blobs -File -Filter *.xml

  foreach ($XMLFile in $LocalXMLFiles) {

    $TicketXML = [Xml] (Get-Content -Path "$($XMLFile.FullName)")

    try {

      $UserId = $TicketXML.userAction.userId

      $ADUser = Get-ADUser -Identity $UserId -Properties DistinguishedName, sAMAccountName |
      Select-Object DistinguishedName, sAMAccountName
    }
    catch {

      #Write-Output "Send error message to SF $($Error[0].Exception.Message)"

      $Body = @"
<pre>
Username: $($UserId)
Ticket#:  $($TicketXML.userAction.ticketnumber)
RefId:    $($TicketXML.userAction.RefId)
Error:    $($Error[0].Exception.Message)
</pre>
"@
      $EmailParams = @{
        to         = "sconnea@sonymusic.com"
        from       = 'PwSh Alerts pwsh@sonymusic.com'
        subject    = "Account access not extended. Ticket# $($TicketXML.userAction.ticketnumber)"
        smtpserver = 'cmailsony.servicemail24.de'
        body       = ($Body | Out-String)
        bodyashtml = $true
      }

      Send-MailMessage @EmailParams 3>$null
      Write-Output "What if: Sending error email, user: $($UserId)"
      $ADUser = $null
    }

    if ($ADUser) {

      $ExpiresDate = [datetime]::parseexact((($TicketXML.userAction).expdate), 'yyyy-MM-dd HH:mm:ss', $null).ToString('MM/dd/yyyy')

      Set-ADAccountExpiration -Identity $($ADUser.DistinguishedName) -DateTime $ExpiresDate -WhatIf

      $Body = @"
<pre>
Username:    $($UserId)
Ticket#:     $($TicketXML.userAction.ticketnumber)
RefId:       $($TicketXML.userAction.RefId)
ExpiresDate: $($ExpiresDate)
</pre>
"@
      $EmailParams2 = @{
        to         = "sconnea@sonymusic.com"
        from       = 'PwSh Alerts pwsh@sonymusic.com'
        subject    = "Account access extended. Ref# $($TicketXML.userAction.RefId)"
        smtpserver = 'cmailsony.servicemail24.de'
        body       = ($Body | Out-String)
        bodyashtml = $true
      }

      Send-MailMessage @EmailParams2 3>$null
      Write-Output "What if: Sending success email, user: $($UserId)"
      $ADUser = $null
    }
  }

  Remove-Item -Path "" -Force
  Start-Sleep -Seconds 60
}
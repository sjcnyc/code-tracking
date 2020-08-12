Import-Module Az
$ErrorActionPreference = "Continue"
$ADUser = $null
$LocalXMLPath = "D:\ExtNetAcctLogs"
$TicketPath = "$($LocalXMLPath)\Tickets"
$LogPath = "$($LocalXMLPath)\Logs"
$LogName = "UpdatedAccountsLog.csv"
$ConnectionString = "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=sa01sftx3406815508;AccountKey=2u6z1WymVz3kYLZZa+xHsLdZSvDYQLXVMN/V27TMUgQe6XKE2bUYyVySBjvC5ps0XHo/nsqSRjufyScGVg7f4Q=="
$SourceStorageContext = New-AzStorageContext -ConnectionString $ConnectionString
$SrcContainer = "con01-sf-dropoff"
#$DestContainer         = "con01-sf-archive"
$Cred = Get-AutomationPSCredential -Name 'T2_Cred'

$Blobs = Get-AzStorageBlob -Container $SrcContainer -Context $SourceStorageContext | Where-Object { $_.name -like "00*" }

if ($Blobs) {

  foreach ($Blob in $Blobs) {

    Write-Output $Blob.Name

    $getAzStorageBlobContentSplat = @{
      Blob        = $Blob.Name
      Container   = $SrcContainer
      Destination = $LocalXMLPath
      Context     = $SourceStorageContext
    }

    Get-AzStorageBlobContent @getAzStorageBlobContentSplat -Force

    <#     $startAzStorageBlobCopySplat = @{
      SrcBlob       = $Blob.Name
      Context       = $SourceStorageContext
      SrcContainer  = $SrcContainer
      DestContainer = $DestContainer
      DestBlob      = $Blob.Name
    }

    Start-AzStorageBlobCopy @startAzStorageBlobCopySplat -Force #>

    Get-AzStorageBlob -Context $SourceStorageContext -Container $SrcContainer -Blob $Blob.Name | Remove-AzStorageBlob

    $LocalXMLFiles = Get-ChildItem -Path $LocalXMLPath -File -Filter *.xml

    foreach ($XMLFile in $LocalXMLFiles) {

      $TicketXML = [Xml] (Get-Content -Path "$($XMLFile.FullName)")

      try {

        $UserId = $TicketXML.userAction.userId

        $ADUser = Get-ADUser -Identity $UserId -Properties DistinguishedName, sAMAccountName, accountExpires, Name | 
        Select-Object DistinguishedName, sAMAccountName, Name, @{N = "ExpiryDate"; E = { [datetime]::FromFileTime($_.accountExpires) } }
      }
      catch {

        Write-Output "$($Error[0].Exception.Message)"

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
          from       = 'PwSh Alerts pwshalerts@sonymusic.com'
          subject    = "Account access not extended. Ticket# $($TicketXML.userAction.ticketnumber)"
          smtpserver = 'cmailsony.servicemail24.de'
          body       = ($Body | Out-String)
          bodyashtml = $true
        }

        Send-MailMessage @EmailParams 3>$null
        Write-Output "Sending error email, user: $($UserId)"
        $ADUser = $null
      }

      if ($ADUser) {

        $ExpiresDate = [datetime]::parseexact((($TicketXML.userAction).expdate), 'yyyy-MM-dd HH:mm:ss', $null).ToString('MM/dd/yyyy HH:mm:ss tt')

        Set-ADAccountExpiration -Identity $($ADUser.DistinguishedName) -DateTime $ExpiresDate -Credential $Cred

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
          from       = 'PwSh Alerts pwshalerts@sonymusic.com'
          subject    = "Account access extended. Ref# $($TicketXML.userAction.RefId)"
          smtpserver = 'cmailsony.servicemail24.de'
          body       = ($Body | Out-String)
          bodyashtml = $true
        }

        Send-MailMessage @EmailParams2 3>$null
        Write-Output "Sending success email, user: $($UserId)"
      
        $UserObject = [pscustomobject]@{
          Name              = $ADUser.Name
          SamAccountName    = $ADUser.sAMAccountName
          DistinguishedName = $ADUser.DistinguishedName
          AccountExpires    = ($ADUser.ExpiryDate).ToString('MM/dd/yyyy HH:mm:ss tt') 
          NewAccountExpires = $ExpiresDate 
          Scriptexecution   = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss tt')
        }

        $UserObject | Export-Csv "$($LogPath)\$($LogName)" -NoType -Append

        $ADUser = $null
      }
    }
    Move-Item -Path "$($LocalXMLPath)\$($Blob.Name)" -Destination "$($TicketPath)\$($Blob.Name)" -Force
  }
}
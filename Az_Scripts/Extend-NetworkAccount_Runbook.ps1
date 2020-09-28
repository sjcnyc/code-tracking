
Import-Module Az
$ErrorActionPreference = "Continue"
$ADUser = $null
$LocalXMLPath = "D:\ExtNetAcctLogs"
#$LocalXMLPath = "\\storage.me.sonymusic.com\wwinfra$\ExtNetAcctLogs"
$TicketPath = "$($LocalXMLPath)\Tickets"
$LogPath = "$($LocalXMLPath)\Logs"
$LogName = "UpdatedAccountsLog.csv"
$ConnectionString = "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=sa01sftx3406815508;AccountKey=2u6z1WymVz3kYLZZa+xHsLdZSvDYQLXVMN/V27TMUgQe6XKE2bUYyVySBjvC5ps0XHo/nsqSRjufyScGVg7f4Q=="
$SourceStorageContext = New-AzStorageContext -ConnectionString $ConnectionString
$SrcContainer = "con01-sf-dropoff"
#$DestContainer = "con01-sf-archive"
$Cred = Get-AutomationPSCredential -Name 'T2_Cred'

Write-Output "Getting XML Files..."
$Blobs = Get-AzStorageBlob -Container $SrcContainer -Context $SourceStorageContext #| Where-Object { $_.name -like "00*" }

if ($Blobs) {

  foreach ($Blob in $Blobs) {

    Write-Output "Processing: $($Blob.Name)"

    $getAzStorageBlobContentSplat = @{
      Blob        = $Blob.Name
      Container   = $SrcContainer
      Destination = $LocalXMLPath
      Context     = $SourceStorageContext
    }

    Get-AzStorageBlobContent @getAzStorageBlobContentSplat -Force
    Write-Output "Copying: $($Blob.Name) to: $($LocalXMLPath)"

    <#     $startAzStorageBlobCopySplat = @{
      SrcBlob       = $Blob.Name
      Context       = $SourceStorageContext
      SrcContainer  = $SrcContainer
      DestContainer = $DestContainer
      DestBlob      = $Blob.Name
    } #>

    #Start-AzStorageBlobCopy @startAzStorageBlobCopySplat -Force

    Get-AzStorageBlob -Context $SourceStorageContext -Container $SrcContainer -Blob $Blob.Name | Remove-AzStorageBlob
    Write-Output "Removing: $($Blob.Name)"

    # $LocalXMLFiles = Get-ChildItem -Path $LocalXMLPath -File -Filter *.xml
    $LocalXMLFile = Get-ChildItem -Path $LocalXMLPath -File -Filter $Blob.Name
    Write-Output "Processing: $($LocalXMLFile)"

    #foreach ($XMLFile in $LocalXMLFiles) {

    $TicketXML = [Xml] (Get-Content -Path "$($LocalXMLFile.FullName)")

    try {

      $UserId = $TicketXML.userAction.userId

      $ADUser = Get-ADUser -Identity $UserId -Properties DistinguishedName, sAMAccountName, accountExpires, Name |
      Select-Object DistinguishedName, sAMAccountName, Name, @{N = "ExpiryDate"; E = { [datetime]::FromFileTime($_.accountExpires) } }
      Write-Output "Getting properties for: $($ADUser.samaccountname)"
    }
    catch {

      Write-Output "$($Error[0].Exception.Message)"
        
      if ($null -eq $ADUser.samaccountname) {
        $UserId = "N/A"
      }

      $Body = @"
<pre>
UserId:   $($UserId)
Ticket#:  $($TicketXML.userAction.ticketnumber)
Error:    $($Error[0].Exception.Message)
</pre>
"@

      $Body2 = @"
<pre>
UserId:   $($UserId)
Ticket#:  $($TicketXML.userAction.ticketnumber)
RefId:    $($TicketXML.userAction.RefId)
Error:    $($Error[0].Exception.Message)
</pre>
"@
      $EmailParams = @{
        to         = "sconnea@sonymusic.com", "Salesforce.Requests@sonymusic.com"
        from       = 'PwSh Alerts pwshalerts@sonymusic.com'
        subject    = "Account access not extended. Ticket# $($TicketXML.userAction.ticketnumber)"
        smtpserver = 'cmailsony.servicemail24.de'
        body       = ($Body | Out-String)
        bodyashtml = $true
      }

      Send-MailMessage @EmailParams 3>$null

      $EmailParams2 = @{
        to         = "sconnea@sonymusic.com", "salesforce.requests@4-umsi1z03v0oznmvjd6i9do7wep3916t0e9wojknoc39w61pd0.7-jlcaeao.na33.case.salesforce.com"
        from       = 'PwSh Alerts pwshalerts@sonymusic.com'
        subject    = "Account access not extended. Ticket# $($TicketXML.userAction.ticketnumber)"
        smtpserver = 'cmailsony.servicemail24.de'
        body       = ($Body2 | Out-String)
        bodyashtml = $true
      }

      Send-MailMessage @EmailParams2 3>$null
      Write-Output "Sending error email, user: $($UserId)"
      $ADUser = $null
    }

    if ($ADUser) {

      $ExpiresDate = [datetime]::parseexact((($TicketXML.userAction).expdate), 'yyyy-MM-dd HH:mm:ss', $null).ToString('MM/dd/yyyy HH:mm:ss tt')

      Set-ADAccountExpiration -Identity $($ADUser.DistinguishedName) -DateTime $ExpiresDate -Credential $Cred

      $NewAccountexpires = Get-ADUser -Identity $UserId -Properties accountExpires, Name | 
      Select-Object @{N = "ExpiryDate"; E = { [datetime]::FromFileTime($_.accountExpires) } }
      Write-Output "Updating expiry date for: $($UserId)"

      $Body = @"
<pre>
UserId:      $($UserId)
Ticket#:     $($TicketXML.userAction.ticketnumber)
RefId:       $($TicketXML.userAction.RefId)
ExpiresDate: $(($NewAccountexpires.ExpiryDate).ToString('MM/dd/yyyy HH:mm:ss tt')) 
</pre>
"@
      $EmailParams3 = @{
        to         = "sconnea@sonymusic.com", "extend.account@sonymusic.com", "salesforce.requests@4-umsi1z03v0oznmvjd6i9do7wep3916t0e9wojknoc39w61pd0.7-jlcaeao.na33.case.salesforce.com"
        from       = 'PwSh Alerts pwshalerts@sonymusic.com'
        subject    = "Account access extended. Ref# $($TicketXML.userAction.RefId)"
        smtpserver = 'cmailsony.servicemail24.de'
        body       = ($Body | Out-String)
        bodyashtml = $true
      }

      Send-MailMessage @EmailParams3 3>$null
      Write-Output "Sending success email, user: $($UserId)"
      
      $UserObject = [pscustomobject]@{
        Name              = $ADUser.Name
        SamAccountName    = $ADUser.sAMAccountName
        DistinguishedName = $ADUser.DistinguishedName
        AccountExpires    = ($ADUser.ExpiryDate).ToString('MM/dd/yyyy HH:mm:ss tt') 
        NewAccountExpires = ($NewAccountexpires.ExpiryDate).ToString('MM/dd/yyyy HH:mm:ss tt') 
        Scriptexecution   = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss tt')
      }

      $UserObject | Export-Csv "$($LogPath)\$($LogName)" -NoType -Append
      "Updating Log: $($LogPath)\$($LogName)"

      $ADUser = $null
    }
    Move-Item -Path "$($LocalXMLFile.FullName)" -Destination "$($TicketPath)\$($LocalXMLFile.Name)" -Force
    Write-Output "Moving: $($LocalXMLFile.Name) to: $($TicketPath)\$($LocalXMLFile.Name)"
    #}
  }
  Write-Output "Loop Complete."
}
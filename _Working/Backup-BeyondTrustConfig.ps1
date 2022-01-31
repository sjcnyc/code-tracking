$Style1 =
'<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
</style>'

$Date = Get-Date -Format 'MMddyyyy_HHmm'
$Path = '\\storage.me.sonymusic.com\wwinfra$\BeyondTrust_backups\'
$Url = 'https://sonymusic.beyondtrustcloud.com'
$Auth = @{Authorization = 'Basic MTg2YjVhNjBkYjQ2ZWRjNDA5ZWYyZmNjNjFjOGJhMWNmYTE5ZDVhNzprYmxLdWp4OE45ZU44ZlVFdHBrTEJzNlJBbGU0cTl1WTZTOUpXenl2bFJrSw==' }
$Body = @{grant_type = 'client_credentials' }

$Response = Invoke-RestMethod -Uri "$($Url)/oauth2/token" -Method POST -Headers $Auth -UseBasicParsing -Body $Body

Write-Output "POST: $Response"

$Token = ($Response).access_token

Write-Output "Token: $Token"

$Headers = @{Authorization = "Bearer $($Token)" }
Invoke-RestMethod -Uri "$($Url)/api/backup" -Method GET -Headers $Headers -UseBasicParsing | Out-File "$($Path)BeyondTrustbackup_$($Date).nsb"

$InfoBody = [pscustomobject]@{
  'Task' = 'Beyond Trust Configuration Backup'
  'Path' = "$($Path)"
  'File' = "BeyondTrustbackup_$($Date).nsb"
}

$HTML = New-HTMLHead -title 'Beyond Trust Configuration Backup' -style $Style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$EmailParams = @{
  to         = 'sam.mercado.aligncommunications@sonymusic.com', 'brian.lynch@sonymusic.com'
  cc         = 'sconnea@sonymusic.com'
  from       = 'PwSh Alerts pwshalerts@sonymusic.com'
  subject    = 'Beyond Trust Configuration Backup'
  smtpserver = 'cmailsony.servicemail24.de'
  Body       = ($HTML | Out-String)
  BodyAsHTML = $true
}

Send-MailMessage @EmailParams
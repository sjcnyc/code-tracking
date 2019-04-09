#$cred = Get-AutomationPSCredential -Name 'T2_Cred'

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


$Date = (get-date -f yyyy-MM-dd)
$CSVFile = "c:\support\Users_Created_Last_day_$($Date).csv"
$attachcsv = $false
$When = ((Get-Date).AddDays(-1)).Date
$filter = [regex]'^*OU=Service*|^*OU=ADM*|^*OU=NewSync*^*OU=Test'

$getADUserSplat = @{
    Filter = {whenCreated -ge $When}
    Properties = '*'
    Credential = $cred
    server = "me.sonymusic.com"
}
$selectObjectSplat = @{
    Property = 'UserPrincipalName', 'SamAccountName', 'Surname', 'GivenName', 'DistinguishedName', 'Enabled', 'WhenCreated'
}
$LastDay = Get-ADUser @getADUserSplat |Where-Object {$_.DistinguishedName -notMatch $filter} |Select-Object @selectObjectSplat

if ($LastDay.Length -gt 0) {
  $msg = "See Attached CSV Report"
  $Count = $LastDay.Count
  $LastDay |Export-Csv -Path $CSVFile -NoTypeInformation
  $attachcsv = $true
}
else {
  $Msg = ""
  $Count = '0'
}

$HTML = New-HTMLHead -title "Users Created in the Last day" -style $Style1
$HTML += "<h3>Users Created in the Last day.</h3>"
$HTML += "<h4>$($Msg)</h4>"
$HTML += "<h4>Users Created: $($Count)"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" |Close-HTML

$EmailParams = @{
  to         = 'sconnea@sonymusic.com'
  #cc          = 'Alex.Moldoveanu@sonymusic.com', 'sconnea@sonymusic.com'
  from       = 'adjob@sonymusic.com'
  subject    = 'Users Created in the Last day'
  smtpserver = 'cmailsony.servicemail24.de'
  Body       = ($HTML |Out-String)
  BodyAsHTML = $true
}
if ($attachcsv) {
  Send-MailMessage @EmailParams -Attachments $CSVFile
}
else {
  Send-MailMessage @EmailParams
}
#   to          = 'hrsystems@sonymusic.com'
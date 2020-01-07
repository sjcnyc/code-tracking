$cred = Get-AutomationPSCredential -Name 'T2_Cred'

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
$CSVFile = "C:\Support\Temp\UPNs_Changed_Last_day_$($Date).csv"
$attachcsv = $false

$ReferenceCSV = (Import-CSV "C:\Support\Temp\Reference.csv").Where{ ![string]::IsNullOrWhiteSpace($_.userPrincipalName) -or $_.userPrincipalName -ne $null }

$Lookup = $ReferenceCSV | Group-Object -AsHashTable -AsString -Property sAMAccountName

$getADUserSplat = @{
  Properties = 'Name', 'sAMAccountName', 'userPrincipalName'
  SearchBase = "OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
  LDAPFilter = "(samAccountType=805306368)(!userAccountControl:1.2.840.113556.1.4.803:=2)"
  Credential = $cred
}

$GetUser = Get-ADUser @getADUserSplat | Select-Object $getADUserSplat.Properties 
$GetUser | Export-Csv "C:\Support\Temp\Difference.csv" -NoTypeInformation

$Results = Import-Csv -Path "C:\Support\Temp\Difference.csv" | ForEach-Object {
  $Samname = $_.sAMAccountName
  if ($Lookup.ContainsKey($Samname)) {
    $OldUPN = ($Lookup[$Samname]).userPrincipalName
  }
  else {
    $OldUPN = "Unknown"
  }
  if ($_.userPrincipalName -ne $OldUPN -and $OldUPN -ne "Unknown") {
    [pscustomobject]@{
      sAMAccontName = $Samname
      Name          = $_.Name
      OldUPN        = $OldUPN
      NewUPN        = $_.userPrincipalName
    }
  }
}

#$Results | Out-GridView
if ($null -ne $Results ) {

  $msg = "See Attached CSV Report"
  $Count = $Results.Count
  $Results | Export-Csv -Path $CSVFile -NoTypeInformation
  $attachcsv = $true
}
else {
  $msg = ""
  $Count = '0'
}

$InfoBody = [pscustomobject]@{
  'Task'   = "Azure Hybrid Runbook Worker - Tier-2"
  'Action' = "UPNs Changes in the Last Day"
  "Count"  = $Count
}

$HTML = New-HTMLHead -title "UPNs Changes in the Last Day" -style $Style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
$HTML += "<h4>$($Msg)</h4>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$EmailParams = @{
  to         = "sconnea@sonymusic.com" #, "Alex.Moldoveanu@sonymusic.com"
  from       = 'PwSh Alerts pwshalerts@sonymusic.com'
  subject    = 'UPNs Changes in the Last Day'
  smtpserver = 'cmailsony.servicemail24.de'
  Body       = ($HTML | Out-String)
  BodyAsHTML = $true
}
if ($attachcsv) {
  Send-MailMessage @EmailParams -Attachments $CSVFile
}
else {
  Send-MailMessage @EmailParams
}

Start-Sleep 5

Get-ChildItem -Path "C:\Support\Temp" -Filter "*.csv" | ForEach-Object { Remove-Item -Path $_.FullName }
Start-Sleep 5
$GetUser | Export-Csv "C:\Support\Temp\Reference.csv" -NoTypeInformation
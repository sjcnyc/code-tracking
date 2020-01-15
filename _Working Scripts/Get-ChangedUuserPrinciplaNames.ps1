$Cred = Get-AutomationPSCredential -Name 'T2_Cred'
$Server = (Get-ADDomainController -Credential $Cred).HostName
$When = ((Get-Date).AddDays(-1)).Date
$Date = (get-date -f yyyy-MM-dd)
$CSVFile = "C:\Support\Temp\UPNs_Changed_Last_day_$($Date).csv"
$attachcsv = $false

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

$getADUserSplat = @{
  Properties = 'Name', 'sAMAccountName', 'userPrincipalName', 'DistinguishedName', 'CanonicalName', 'whenCreated'
  SearchBase = "OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
  LDAPFilter = "(samAccountType=805306368)(!userAccountControl:1.2.840.113556.1.4.803:=2)"
  Credential = $Cred
}

$getADReplicationAttributeMetadataSplat = @{
  Server     = $Server
  Attribute  = "userprincipalname"
  Filter     = { LastOriginatingChangeTime -gt $When }
  Credential = $Cred
}

$Results = Get-ADUser @getADUserSplat -PipelineVariable usr | Get-ADReplicationAttributeMetadata @getADReplicationAttributeMetadataSplat |
ForEach-Object {

  [pscustomobject]@{
    sAMAccountname = $usr.sAMAccountName
    Name           = $usr.Name
    UPN            = $_.AttributeValue
    WhenCreated    = $usr.WhenCreated
    WhenChanged    = $_.LastOriginatingChangeTime
    DN             = $usr.DistinguishedName
  }
}

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
  to         = 'hrsystems@sonymusic.com'
  cc         = 'Alex.Moldoveanu@sonymusic.com', 'sconnea@sonymusic.com'
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
Start-Sleep 2
Remove-Item -Path $CSVFile
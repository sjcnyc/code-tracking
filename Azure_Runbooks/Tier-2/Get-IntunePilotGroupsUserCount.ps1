$AutomationPSCredentialName = "T2_Cloud_Cred"
$Date = (get-date -f yyyy-MM-dd)
$Credential = Get-AutomationPSCredential -Name $AutomationPSCredentialName
$AZ_IntuneLocalPilot_Id = "7d0d9813-c259-41e5-b5eb-30afcda5cfcb"
$AZ_IntuneCAPilot_Id = "9adb0088-ead1-434a-86f5-4c03cf5d1313"

$AZ_IntuneLocalPilot_Csv = "C:\support\AZ_IntuneLocalPilot_Report_$($Date).csv"
$AZ_IntuneCAPilot_Csv = "C:\support\AZ_IntuneCAPilot_Report_$($Date).csv"

$CSVFiles = @()

$Style1 =
'<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 10pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
  </style>'

Write-Output "Connecting to Msol"
Connect-MsolService -Credential $Credential -ErrorAction SilentlyContinue

Write-Output "Getting Groups"
$AZ_IntuneLocalPilot_Users = Get-MsolGroupMember -GroupObjectId $AZ_IntuneLocalPilot_Id
$AZ_IntuneCAPilot_Users = Get-MsolGroupMember -GroupObjectId $AZ_IntuneCAPilot_Id

$AZ_IntuneLocalPilot_Count = $AZ_IntuneLocalPilot_Users.Count
$AZ_IntuneCAPilot_Count = $AZ_IntuneCAPilot_Users.Count

$AZ_IntuneLocalPilot = [pscustomobject]@{
  'Task'            = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'          = "User Count"
  'Group'           = "AZ_IntuneLocalPilot"
  'Total Users'     = $AZ_IntuneLocalPilot_Count
}

$AZ_IntuneCAPilot = [pscustomobject]@{
  'Task'            = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'          = "User Count"
  'Group'           = "AZ_IntuneCAPilot"
  'Total Users'     = $AZ_IntuneCAPilot_Count
}

if ($null -ne $AZ_IntuneLocalPilot_Count) {
    $AZ_IntuneLocalPilot_Users | Export-Csv $AZ_IntuneLocalPilot_Csv -NoTypeInformation
    $CSVFiles += $AZ_IntuneLocalPilot_Csv
  }

  if ($null -ne $AZ_IntuneCAPilot_Count) {
    $AZ_IntuneCAPilot_Users | Export-Csv $AZ_IntuneCAPilot_Csv -NoTypeInformation
    $CSVFiles += $AZ_IntuneCAPilot_Csv
  }

$HTML = New-HTMLHead -title "Intune Pilot Report" -style $Style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $AZ_IntuneLocalPilot)
$HTML += "<br>"
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $AZ_IntuneCAPilot)
$HTML += "<h4>See Attached CSV Report</h4>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$EmailParams = @{
  To          = "sconnea@sonymusic.com"#, "intune_automation_reports@sonymusic.com"
  From        = 'PwSh Alerts poshalerts@sonymusic.com'
  Subject     = "Intune Pilot Reports"
  SmtpServer  = 'cmailsony.servicemail24.de'
  Body        = ($HTML | Out-String)
  BodyAsHTML  = $true
  Attachments = $CSVFiles
}
Write-Output "Sending Email"
Send-MailMessage @EmailParams
Start-Sleep -Seconds 5
foreach ($Item in $CSVFiles) {
  Remove-Item $item
}
# finished for now
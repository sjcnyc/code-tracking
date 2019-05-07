using namespace System.Collections.Generic

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

$cred              = Get-AutomationPSCredential -Name 'T2_Cred'
$Date              = (get-date -f yyyy-MM-dd)
$CSVFile           = "C:\support\Users_Removed_From_AZ_Troubleshooting_$($Date).csv"
$Attachment        = $false
$UserCounter       = 0
$PListUsersRemoved = [List[psobject]]::new()
$GroupName         = "AZ_Troubleshooting"
$ScriptStartedTime = (Get-Date -Format G)

$Users = Get-ADGroup -Identity $GroupName -Credential $cred | Get-ADGroupMember -Recursive -Credential $cred

try {

  foreach ($User in $Users) {
    $UserCounter ++
    $U = Get-ADUser $User.SamAccountName -Credential $cred | Select-Object Name, SamAccountName, UserPrincipalName
    $PSObj = [pscustomobject]@{
      User           = $U.Name
      UPN            = $U.UserPrincipalName
      SamAccountName = $U.SamAccountName
    }
    [void]$PListUsersRemoved.Add($PSObj)
  }

  $SyncUsers = [PSCustomObject]@{
    'Task'          = "Azure Hybrid Runbook Worker - Tier-2"
    'Action'        = "Remove Mfa Users from $($GroupName)"
    'Users Removed' = $UserCounter
  }

  $HTML = New-HTMLHead -title "Remove Users From $($GroupName)" -style $Style1
  $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $SyncUsers)

  if ($UserCounter -gt 0) {
    $Attachment = $true
    #Get-AdGroup $Groupname -Credential $cred | Set-ADGroup -clear member -Credential $cred
    Write-Output "Clearing users from group $($GroupName)"
    $PListUsersRemoved | Export-Csv $CSVFile -NotypeInformation
    $HTML += "<h4>See Attached CSV Report(s)</h4>"
  }

  $HTML += "<h4>Script Started: $($ScriptStartedTime)</h4>"
  $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

  $EmailParams = @{
    To         = "sconnea@sonymusic.com", "Alex.Moldoveanu@sonymusic.com", "bobby.thomas@sonymusic.com", "heather.guthrie@sonymusic.com", "brian.lynch@sonymusic.com", "Rohan.Simpson@sonymusic.com"
    CC         = "jorge.ocampo.peak@sonymusic.com", "Steve.Kenton@sonymusic.com", "suminder.singh.itopia@sonymusic.com"
    From       = 'PwSh Alerts pwshalerts@sonymusic.com'
    Subject    = "Remove Users From $($GroupName)"
    SmtpServer = 'cmailsony.servicemail24.de'
    Body       = ($HTML | Out-String)
    BodyAsHTML = $true
  }

  if ($Attachment) {
    Send-MailMessage @EmailParams -Attachments $CSVFile
    Start-Sleep -Seconds 5
    Remove-Item $CSVFile
  }
  else {
    Send-MailMessage @EmailParams
  }
}
catch {
  $_.Exception.Message
}
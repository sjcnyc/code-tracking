using namespace System.Collections.Generic

Import-Module "C:\Users\sconnea\Documents\WindowsPowerShell\Modules\Okta.Core.Automation\1.0.1\Okta.Core.Automation.psd1" |Out-Null

Connect-Okta -Token "00jCWv0g5qQK98CQN_zG9tlwvyMyFCpFBE8t5UCzNb" -FullDomain "https://sonymusic.okta.com"

$TotalEnrolled = 0
$Date = (get-date -f yyyy-MM-dd)
$CSVFile = "C:\Support\OktaMFA_Enrollerd_User_Report_$($Date).csv"

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

$OktaUser = Get-oktauser

$PSList = [List[psobject]]::new()

foreach ($User in $OktaUser) {

  $MfaEnabled = $false
  $Factor = $null
  $Status = $null
  $FactorInfo = Get-OktaUserFactor -IdOrLogin $user.Id

  switch ($factorInfo.FactorType) {
    'sms'                 {$mfaenabled = $true; $Factor = $FactorInfo.FactorType; $Status = $FactorInfo.Status}
    'call'                {$mfaenabled = $true; $Factor = $FactorInfo.FactorType; $Status = $FactorInfo.Status}
    'push'                {$mfaenabled = $true; $Factor = $FactorInfo.FactorType; $Status = $FactorInfo.Status}
    'token:software:totp' {$MfaEnabled = $true; $Factor = $FactorInfo.FactorType; $Status = $FactorInfo.Status}
    'token:hardware'      {$MfaEnabled = $true; $Factor = $FactorInfo.FactorType; $Status = $FactorInfo.Status}
    Default {}
  }

  $PSobj = [PSCustomObject]@{
    Name        = $User.Profile.Login
    Factors     = $Factor -join ' | ';
    Status      = $Status -join ' | ';
    MfaEnrolled = $MfaEnabled
  }

  [void]$PSList.Add($PSobj)
  if ($MfaEnabled) {$TotalEnrolled ++}
}

$PSList | Export-Csv $CSVFile -NoTypeInformation

$InfoBody = [pscustomobject]@{
  'Task'               = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'             = "Okta MFA Enrolled Users Report"
  "Total MFA Enrolled" = $TotalEnrolled
}

$HTML = New-HTMLHead -title "Okta MFA Enrolled Users Report" -style $Style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
$HTML += "<h4>See Attached CSV Report</h4>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" |Close-HTML

$EmailParams = @{
  To          = "sean.connealy@sonymusic.com"
  From        = 'PwSh Alerts poshalerts@sonymusic.com'
  Subject     = "Okta MFA Enrolled Users Report"
  SmtpServer  = 'cmailsony.servicemail24.de'
  Body        = ($HTML |Out-String)
  BodyAsHTML  = $true
  Attachments = $CSVFile
}

Send-MailMessage @EmailParams
Start-Sleep -Seconds 5
Remove-Item $CSVFile
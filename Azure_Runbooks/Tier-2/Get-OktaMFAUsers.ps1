#Requires -Module OktaAPI
Import-Module OktaAPI

# requires OktaAPI: https://github.com/gabrielsroka/OktaAPI.psm1
Connect-Okta "00jCWv0g5qQK98CQN_zG9tlwvyMyFCpFBE8t5UCzNb" "https://sonymusic.okta.com"
function Get-MfaUsers() {
  $totalUsers = 0
  $mfaUsers = @()
  $Date = (get-date -f yyyy-MM-dd)
  $CSVFile = "C:\Support\OktaMFA_Report_$($Date).csv"

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

  # for more filters, see https://developer.okta.com/docs/api/resources/users#list-users-with-a-filter
  $params = @{filter = 'status eq "ACTIVE"'}
  do {
    $page = Get-OktaUsers @params
    $users = $page.objects
    foreach ($user in $users) {
      $factors = Get-OktaFactors $user.id

      $sms        = $factors.where( {$_.factorType -eq "sms"})
      $call       = $factors.where( {$_.factorType -eq "call"})
      $push       = $factors.where( {$_.factorType -eq "push"})
      $web        = $factors.where( {$_.factorType -eq "web"})
      $email      = $factors.where( {$_.factorType -eq "email"})
      $token      = $factors.where( {$_.factorType -like "token"})
      $tokenH     = $factors.where( {$_.factorType -like "token:hardware*"})
      $tokenS     = $factors.where( {$_.factorType -like "token:software*"})
      $tokenSokta = $factors.where( {$_.factorType -like "token:software*" -and $_.provider -eq "OKTA"})
      $tokenSgoog = $factors.where( {$_.factorType -like "token:software*" -and $_.provider -eq "GOOGLE"})

      $mfaUsers += [PSCustomObject]@{
        id                             = $user.id
        name                           = $user.profile.login
        sms                            = $sms.factorType
        sms_enrolled                   = $sms.created
        sms_status                     = $sms.status
        call                           = $call.factorType
        call_enrolled                  = $call.created
        call_status                    = $call.status
        push                           = $push.factorType
        push_enrolled                  = $push.created
        push_status                    = $push.status
        web                            = $web.factorType
        web_enrolled                   = $web.created
        web_status                     = $web.status
        email                          = $email.factorType
        email_enrolled                 = $email.created
        email_status                   = $email.status
        token                          = $token.factorType
        token_enrolled                 = $token.created
        token_status                   = $token.status
        token_provider                 = $token.provider
        token_vender                   = $tokenHvender
        token_hardware                 = $tokenH.factorType
        token_hardware_enrolled        = $tokenH.created
        token_hardware_status          = $tokenH.status
        token_hardware_provider        = $tokenH.provider
        token_hardware_vender          = $tokenH.vender
        token_software                 = $tokenS.factorType
        token_software_enrolled        = $tokenS.created
        token_software_status          = $tokenS.status
        token_software_provider        = $tokenS.provider
        token_software_vender          = $tokenS.vender
        token_software_okta            = $tokenSokta.factorType
        token_software_okta_enrolled   = $tokenSokta.created
        token_software_okta_status     = $tokenSokta.status
        token_software_okta_provider   = $tokenSokta.provider
        token_software_okta_vender     = $tokenSokta.vender
        token_software_google          = $tokenSgoog.factorType
        token_software_google_enrolled = $tokenSgoog.created
        token_software_google_status   = $tokenSgoog.status
        token_software_google_provider = $tokenSgoog.provider
        token_software_google_vender   = $tokenSgoog.vender
      }
    }
    $totalUsers += $users.count
    $params = @{url = $page.nextUrl}
  }
  while ($page.nextUrl)
  $mfaUsers |Export-Csv $CSVFile -NoTypeInformation

  $InfoBody = [pscustomobject]@{
    'Task'        = "Azure Hybrid Runbook Worker - Tier-2"
    'Action'      = "Okta User MFA Report"
    "Total Users" = $totalUsers
  }

  $HTML = New-HTMLHead -title "Okta User MFA Report" -style $Style1
  $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
  $HTML += "<h4>See Attached CSV Report</h4>"
  $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" |Close-HTML

  $EmailParams = @{
    To          = "sean.connealy@sonymusic.com"
    From        = 'Posh Alerts poshalerts@sonymusic.com'
    Subject     = "Okta User MFA Report"
    SmtpServer  = 'cmailsony.servicemail24.de'
    Body        = ($HTML |Out-String)
    BodyAsHTML  = $true
    Attachments = $CSVFile
  }

  Send-MailMessage @EmailParams
  Start-Sleep -Seconds 5
  Remove-Item $CSVFile
}

Get-MfaUsers
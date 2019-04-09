function Send-PasswordExpiringNotification {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess = $true)]
  param
  (
    [System.Management.Automation.SwitchParameter]
    $SendEmail
  )
  #$cred = Get-AutomationPSCredential -Name 'T2_Cred'
  $StartTime = Get-Date -Format G
  $PSArrayList = New-Object System.Collections.ArrayList
  $Dates = @()
  $DayArray = @(1..7)

  for ($x = 1; $x -lt 7; $x++) {
    $Dates += (get-date).adddays($x).ToLongDateString()
  }

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

  $getADUserSplat = @{
    SearchBase = "OU=Service,OU=Users,OU=GBL,OU=USA,OU=NA,OU=ADM,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
    Properties = '*'
    LDAPFilter = "(manager=*)"
    Server     = "me.sonymusic.com"
  }
  try {
    $Accounts = Get-ADUser @getADUserSplat |Where-Object {$_.SamaccountName -like "svc_*"}

    foreach ($Account in $Accounts) {

      $User =
      Get-ADUser $Account -Properties "Name", "msDS-UserPasswordExpiryTimeComputed" |
        Select-Object -Property "Name", @{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").ToLongDateString()}}

      $Manager =
      Get-ADUser (Get-ADUser $Account  -properties * |Select-Object -ExpandProperty Manager) -properties * |Select-Object EmailAddress, Name

      for ($i = 0; $i -lt $Dates.Length; $i++) {
        switch ($User.PasswordExpiry) {
          $Dates[1] { $Days = '1' }
          $Dates[2] { $Days = '2' }
          $Dates[3] { $Days = '3' }
          $Dates[4] { $Days = '4' }
          $Dates[5] { $Days = '5' }
          $Dates[6] { $Days = '6' }
          $Dates[7] { $Days = '7' }
          Default   { break }
        }
      }
      if ($null -ne $Days -and $Days -in $DayArray) {
        $PSObj = [pscustomobject]@{
          'Service Account'  = $User.Name
          'Account Owner'    = $Manager.Name
          'Password Expires' = $User.PasswordExpiry
          'Days Remaining'   = $Days
        }
        [void]$PSArrayList.Add($PSObj)
        $Days = $null
      }
      if ($PSArrayList.Count -ne '0') {
        if ($SendEmail) {
          $HTML = New-HTMLHead -Title "Service Account Password Expiration" -Style $Style1
          $HTML += "<h3>Service Account Password Expiration</h3>"
          $HTML += "<h4>Azure Hybrid Runbook Worker: Tier-2</h4>"
          $HTML += "<h4>Script started: $($StartTime)</h4>"
          $HTML += New-HTMLTable -InputObject $($PSArrayList)
          $HTML += "<h4>Script completed: $(Get-Date -Format G)</h4>" |Close-HTML

          $EmailParams = @{
            To         = $Manager.EmailAddress
            From       = 'PWSH Alerts poshalerts@sonymusic.com'
            Subject    = 'Service Account Password Expiration'
            SmtpServer = 'cmailsony.servicemail24.de'
            Body       = ($HTML |Out-String)
            BodyAsHTML = $true
          }
          Send-MailMessage @EmailParams
          $PSArrayList = $null
        }
      }
    }
  }
  catch {
    $_.Exception.Message
  }
}

Send-PasswordExpiringNotification -SendEmail
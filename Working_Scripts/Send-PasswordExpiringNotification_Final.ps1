
$expireindays = 20
$Date = Get-Date
$PSArrayList = New-Object System.Collections.ArrayList
$users = @()

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

$ADUserSplat = @{
  LDAPFilter = "(manager=*)"
  properties = 'Name', 'PasswordNeverExpires', 'PasswordExpired', 'PasswordLastSet', 'EmailAddress', 'sAMAccountName', 'Manager'
}

$SearchBase = @"
OU=Service,OU=Users,OU=GBL,OU=USA,OU=NA,OU=ADM,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=Service,OU=Users,OU=GBL,OU=USA,OU=NA,OU=ADM,OU=Tier-1,DC=me,DC=sonymusic,DC=com
"@ -split [environment]::NewLine

foreach ($sb in $SearchBase) {
  $users += (Get-ADUser @ADUserSplat -SearchBase $sb).where{ $_.Enabled -eq "True" -and $_.PasswordNeverExpires -eq $false -and $_.passwordexpired -eq $false -and $_.SamaccountName -like "svc_*" }
}

$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users) {

  $tier = ($user.DistinguishedName -like "*Tier-2*") ? "Tier-2" : "Tier-1"

  $manager = Get-ADUser $user.Manager | Select-Object mail, Name

  $passwordSetDate = (Get-ADUser $user -properties * | ForEach-Object { $_.PasswordLastSet })

  $PasswordPol = (Get-ADUserResultantPasswordPolicy $user -ErrorAction 0)
  if ($null -ne ($PasswordPol)) {
    $maxPasswordAge = ($PasswordPol).MaxPasswordAge
  }

  $expireson = $passwordsetdate + $maxPasswordAge
  $today = (Get-Date)
  $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days

  if (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays)) {

    $PSObj = [pscustomobject]@{
      'Service Account'  = $User.Name
      'Account Owner'    = $Manager.Name
      'Password Expires' = $expireson
      'Days Remaining'   = $daystoexpire
    }
    [void]$PSArrayList.Add($PSObj)

    if ($PSArrayList.Count -ne '0') {
      $HTML = New-HTMLHead -Title "Service Account Password Expiration" -Style $Style1
      $HTML += "<h3>$($tier) Service Account Password Expiration</h3>"
      $HTML += "<h4>&nbsp;</h4>"
      $HTML += New-HTMLTable -InputObject $($PSArrayList)
      $HTML += "<h4>Script completed: $(Get-Date -Format G)</h4>" | Close-HTML

      $EmailParams = @{
        To         = 'sconnea@sonymusic.com' #$Manager.EmailAddress
        From       = 'PwSH Alerts poshalerts@sonymusic.com'
        Subject    = "$($tier) Service Account Password Expiration"
        SmtpServer = 'cmailsony.servicemail24.de'
        Body       = ($HTML | Out-String)
        BodyAsHTML = $true
      }
      Send-MailMessage @EmailParams 3>$null
      $PSArrayList.Clear()
    }
  }
}
Get-ADUser -Filter {PasswordNeverExpires -eq $true} -Properties msDS-UserPasswordExpiryTimeComputed |
  Select-Object -Property 'SamAccountName', @{
  Name = 'MustChangePass'; Expression = {
    if ($_.'msDS-UserPasswordExpiryTimeComputed' -eq 0) {
      'True'
    }
    else {
      'False'
    }
  }
}, @{Name = 'PassNotRequired'; Expression = {
    if (Get-ADUser -LDAPFilter "(&(userAccountControl:1.2.840.113556.1.4.803:=32)(!(IsCriticalSystemObject=TRUE)))") {'False'} else {'True'}
  }
} | Export-Csv c:\temp\password_report.csv -NoTypeInformation


$userInfo = @()
Import-Module ActiveDirectory
Get-ADuser -Filter * | ForEach-Object {
  $sAMAccountName = $null
  $sAMAccountName = $_.sAMAccountName
  $pwdExpire = $null
  $pwdExpire = (Get-ADuser $sAMAccountName -Properties "msDS-UserPasswordExpiryTimeComputed")."msDS-UserPasswordExpiryTimeComputed"
  If ($pwdExpire -ne 9223372036854775807) {
    $pwdExpire = Get-Date -Date ([DateTime]::FromFileTime([Int64]::Parse($pwdExpire))) -Format "yyyy-MM-dd HH:mm:ss"
  }
  Else {
    $pwdExpire = "PWD Never Expires"
  }
  $pwdNotRequired = Get-ADUser -LDAPFilter "(&(userAccountControl:1.2.840.113556.1.4.803:=32)(!(IsCriticalSystemObject=TRUE)))"
  if ($pwdNotRequired) {
    $pwdNotRequired = "PWD NOT Required"
  }
  Else {
    'PWD Required'
  }

  $userInfoEntry = "" | Select-Object "Logon Account", "Pwd Expire"
  $userInfoEntry."Logon Account" = $sAMAccountName
  $userInfoEntry."Pwd Expire" = $pwdExpire
  $userInfo += $userInfoEntry
}
$userInfo




#$UsersNoPwdRequired = Get-ADUser -LDAPFilter "(&(userAccountControl:1.2.840.113556.1.4.803:=32)(!(IsCriticalSystemObject=TRUE)))"
#foreach($user in $UsersNoPwdRequired )
#    {
#    Set-ADAccountControl $user -PasswordNotRequired $false
#    }

<#$result = New-Object -TypeName System.Collections.ArrayList
$users = Import-Csv 'C:\Temp\userMustChangePass_004.csv'

foreach ($user in $users) {
  $bmgUser =  Get-ADUser -Identity $user.SamAccountName -Properties 'msDS-UserPasswordExpiryTimeComputed' |
  Select-Object 'SamAccountName', @{
        Name = 'MustChangePassBMG'
        Expression = {
            if ($_.'msDS-UserPasswordExpiryTimeComputed' -eq 0) {
                'True'
            }
            else {
                'False'
            }
        }
    } 
    $info = [pscustomobject]@{
        'SamAccountName' = $user.SamAccountName
        'DisplayName' = $user.DisplayName
        'EmailAddress' = $user.EmailAddress
        'MustChangePass' = $user.MustChangePass
        'MustChangePassBMG' = $bmgUser.MustChangePassBMG
    }
    $null = $result.Add($info)

}
$result | Export-Csv C:\temp\userMustChangePassBMG_001.csv -NoTypeInformation#>
$users = Import-Csv D:\Temp\extend2.csv

foreach ($user in $users) {

  $ADUser = Get-ADUser -Identity $user.UserID  -Properties DistinguishedName, sAMAccountName, accountExpires, Name
  $ExpiresDate = [datetime]::ParseExact(($user.EndDate), 'MM/dd/yyyy', $null).ToString('MM/dd/yyyy HH:mm:ss tt')

  Set-ADAccountExpiration -Identity $($ADUser.DistinguishedName) -DateTime $ExpiresDate -WhatIf

  [pscustomobject]@{
    User = $ADUser.SamAccountName
    Date = $ExpiresDate
  }
}

$serviceaccount = Get-ADUser -Identity "svc_runbook_USA-1" -prop *

if ($serviceaccount.PasswordExpired -eq $true -or $serviceaccount.LockedOut -eq $true) {
  Write-Output "Service account $($serviceaccount.SamAccountName) is locked, or password is expired"
  break
}
else {
  Write-Output "Service account $($serviceaccount.SamAccountName) operational"
}

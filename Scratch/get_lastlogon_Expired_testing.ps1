Import-Module ActiveDirectory
$MaxPwdAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
$expiredDate = (Get-Date).addDays(-$MaxPwdAge)
$ExpiredUsers = Get-ADUser "svc_runblook_USA-2" -Properties PasswordNeverExpires, PasswordLastSet, Mail |
Select-Object samaccountname, PasswordLastSet, @{name = "DaysUntilExpired"; Expression = { $_.PasswordLastSet - $ExpiredDate | Select-Object -ExpandProperty Days } } | Sort-Object PasswordLastSet
$ExpiredUsers




Import-Module ActiveDirectory
$MaxPwdAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
$expiredDate = (Get-Date).addDays(-$MaxPwdAge)
#Set the number of days until you would like to begin notifing the users. -- Do Not Modify --
#Filters for all users who's password is within $date of expiration.
$ExpiredUsers = Get-ADUser -Filter { (PasswordLastSet -gt $expiredDate) -and (PasswordNeverExpires -eq $false) -and (Enabled -eq $true) } -Properties PasswordNeverExpires, PasswordLastSet, Mail | Select-Object samaccountname, PasswordLastSet, @{name = "DaysUntilExpired"; Expression = { $_.PasswordLastSet - $ExpiredDate | Select-Object -ExpandProperty Days } } | Sort-Object PasswordLastSet
$ExpiredUsers



Get-ADUser -Filter { enabled -eq $true } -Properties LastLogonTimeStamp |
Select-Object Name, @{Name = "Stamp"; Expression = { [DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss') } }


function Get-LastLogonEvents {
  try {
    $dcs = Get-ADDomainController -Filter { Name -like "*" }
    $users = Get-ADUser sconnea -prop sAMAccountName

    foreach ($user in $users) {
      foreach ($dc in $dcs) {
        $currentUser = Get-ADUser $user.SamAccountName -Server $dc.HostName -Properties *
        [PSCustomObject]@{
          sAMAccountName     = $user.samaccountname
          DomainController   = $dc.hostname
          LastLogon          = [DateTime]::FromFileTime($currentUser.LastLogon)
          LastLogontimeStamp = [DateTime]::FromFileTime($currentUser.lastLogonTimestamp)
        }
      }
    }
  }
  catch {
    $Error.Message
  }
}

Get-LastLogonEvents
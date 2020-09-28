
$expireindays = 7
$Date = Get-Date

$getAduserSplat = @{
  filter     = '*'
  LDAPFilter = "(manager=*)"
  SearchBase = "OU=Service,OU=Users,OU=GBL,OU=USA,OU=NA,OU=ADM,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
  properties = 'Name', 'PasswordNeverExpires', 'PasswordExpired', 'PasswordLastSet', 'EmailAddress', 'sAMAccountName'
}

$users = (Get-Aduser @getAduserSplat).where{ $_.Enabled -eq "True" -and $_.PasswordNeverExpires -eq $false -and $_.passwordexpired -eq $false -and $_.SamaccountName -like "svc_*" }

$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users) {
  $Name = (Get-ADUser $user | ForEach-Object { $_.Name })

  $Manager =
  Get-ADUser (Get-ADUser $user -properties * | Select-Object -ExpandProperty Manager) -properties * | Select-Object EmailAddress, Name

  #Get Password last set date
  $passwordSetDate = (Get-ADUser $user -properties * | ForEach-Object { $_.PasswordLastSet })
  #Check for Fine Grained Passwords
  $PasswordPol = (Get-ADUserResultantPasswordPolicy $user)
  if ($null -ne ($PasswordPol)) {
    $maxPasswordAge = ($PasswordPol).MaxPasswordAge
  }

  $expireson = $passwordsetdate + $maxPasswordAge
  $today = (Get-Date)
  #Gets the count on how many days until the password expires and stores it in the $daystoexpire var
  $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days

  If (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays)) {
  }

}
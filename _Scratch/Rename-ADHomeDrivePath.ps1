# Grab user in AD.  Please test this before production
$ADUserSplat = @{
  Filter     = { homedirectory -like "\\SMEFR1FLS3P001\PAR-Users*" }
  Properties = 'sAMAccountName', 'HomeDirectory', 'HomeDrive', 'DistinguishedName'
  Server     = 'me.sonymusic.com'
}
$Users = Get-ADUser @ADUserSplat | Select-Object $ADUserSplat.Properties

# Or you can add sAMAccountName manually below
$Users =
@"
sconnea
john001
"@ -split [environment]::NewLine

foreach ($User in $Users) {
  $ADUserSplat = @{
    HomeDrive     = 'U:'
    HomeDirectory = "\\FRAPARPHQFLS001\PAR-Users\$($User.sAMAccountName)"
    Server        = 'me.sonymusic.com'
    WhatIf        = $true # set to $false for production
    Identity      = $User
  }
  Set-ADUser @ADUserSplat
}

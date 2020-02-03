$getADUserSplat = @{
    Filter     = { homedirectory -like "\\USNASPLSYN001*" }
    Properties = 'SamAccountName', 'HomeDirectory', 'HomeDrive', 'DistinguishedName'
    Server     = 'me.sonymusic.com'
}
$Users = Get-ADUser @getADUserSplat | select-object $getADUserSplat.Properties

<# $Users =
@"
sconnea
"@ #>

foreach ($User in $Users) {
  $setADUserSplat = @{
      HomeDrive     = 'H:'
      HomeDirectory = "\\USNASPLSYN001.me.sonymusic.com\home$\$($User.SamAccountName)"
      Server        = 'me.sonymusic.com'
      WhatIf        = $true
      Identity      = $User
  }
  Set-ADUser @setADUserSplat
}

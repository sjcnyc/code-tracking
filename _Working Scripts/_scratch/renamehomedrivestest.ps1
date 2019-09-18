$getADUserSplat = @{
    Filter     = { homedirectory -like "\\storage*" }
    Properties = 'SamAccountName', 'HomeDirectory', 'HomeDrive'
    Server     = 'me.sonymusic.com'
}
$Users = Get-ADUser @getADUserSplat

<# $Users =
@"
sconnea
"@ #>

foreach ($User in $Users) {
  $setADUserSplat = @{
      HomeDrive     = 'H:'
      HomeDirectory = "\\storage.me.sonymusic.com\home$\$($User.SamAccountName)"
      Server        = 'me.sonymusic.com'
      WhatIf        = $true
      Identity      = $User
  }
  Set-ADUser @setADUserSplat
}

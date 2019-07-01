$getADUserSplat = @{
    Filter     = { homedirectory -like "\\storage*home$*" }
    Properties = 'SamAccountName', 'HomeDirectory', 'HomeDrive'
    Server     = 'me.sonymusic.com'
}
$Users = Get-ADUser @getADUserSplat

foreach ($User in $Users) {
  $setADUserSplat = @{
      HomeDrive     = 'H:'
      HomeDirectory = "\\storage.me.sonymusic.com\$($User.SamAccountName)"
      Server        = 'me.sonymusic.com'
      WhatIf        = $true
      Identity      = $User
  }
  Set-ADUser @setADUserSplat
}

$Users = Get-ADUser -Filter {homedirectory -like "\\storage*home$*"} -Properties name, homedirectory, homedrive -Server 'me.sonymusic.com'

foreach ($User in $Users) {
  Set-ADUser -Identity $User -HomeDrive 'H:' -HomeDirectory "\\storage.me.sonymusic.com\$($User.SamAccountName)" -Server 'me.sonymusic.com' -WhatIf
}

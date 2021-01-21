$Users = Get-Content "C:\temp\users.txt"

Foreach ($User in $Users) {
  [PSCustomObject]@{
    User     = $user
    MemberOf = (Get-ADUser -Identity $user -Properties memberof).memberof -replace '^.*?=|,[a-z]{2}=.*$' -notmatch 'sslvpn' -join ','
  }
}
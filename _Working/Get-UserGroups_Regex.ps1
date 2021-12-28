function Get-UserGroups {
  param (
    [Parameter(Mandatory = $true)]
    [array]$UserName
  )

  $results =
  foreach ($User in $UserName) {
    [PSCustomObject]@{
      User     = $User
      MemberOf = (Get-ADUser -Identity $User -Properties memberof).memberof -replace '^.*?=|,[a-z]{2}=.*$' #-notmatch 'sslvpn' -split ','
    }
  }

  $results.MemberOf
}
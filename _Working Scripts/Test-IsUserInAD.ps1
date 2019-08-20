using namespace System.Collections.Generic

function Test-IsUserInAD {
  param (
    [string]$UserName
  )

  $UserList = [List[PSObject]]::new()
  foreach ($Usr in $UserName) {
    try {
      $User = Get-ADUser -Identity $UserName -Properties Displayname, sAMAccountName -Server me.sonymusic.com -ErrorAction Stop
      $Result = $true
    }
    catch {
      $Result = $false
    }

    $PSObject = [pscustomobject]@{
      UserChecked    = $UserName
      SamAccountName = $User.sAMAccountName
      DisplayName    = $User.DisplayName
      InAD           = $Result
    }
    [void]$userlist.Add($PSObject)
  }

  return $UserList
}


@"
LGERVAS
maia007
solty01
kasr001
koel001
kart003
wilk002
data014
"@ -split [environment]::NewLine | ForEach-Object {

  Test-IsUserInAD $_
}
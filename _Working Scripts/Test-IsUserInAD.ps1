using namespace System.Collections.Generic

function Test-IsUserInAD {
  param (
    [string]
    $UserName,

    [string]
    $Domain
  )

  $UserList = [List[PSObject]]::new()
  foreach ($Usr in $UserName) {
    try {
      $getADUserSplat = @{
          Properties  = 'Displayname', 'sAMAccountName'
          Server      = $Domain
          ErrorAction = 'Stop'
          Identity    = $UserName
      }
      $User = Get-ADUser @getADUserSplat
      $Result = $true
    }
    catch {
      $Result = $false
    }

    $PSObject = [pscustomobject]@{
      UserChecked    = $UserName
      SamAccountName = $User.sAMAccountName
      DisplayName    = $User.DisplayName
      IsInAD         = $Result
    }
    [void]$UserList.Add($PSObject)
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

  Test-IsUserInAD $_ -Domain me.sonymusic.com
}
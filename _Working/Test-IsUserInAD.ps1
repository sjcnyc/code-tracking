using namespace System.Collections.Generic

function Test-IsUserInAD {
  param (
    [string]
    $UserName,

    [string]
    $Domain
  )

  $UserList = [List[PSObject]]::new()
  foreach ($User in $UserName) {
    try {

      $getADUserSplat = @{
        Properties  = 'Displayname', 'sAMAccountName', 'mail', 'enabled'
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
ABOOTH
abrown
aelliot
alaidla
ALBE060
"@ -split [environment]::NewLine | ForEach-Object {

  Test-IsUserInAD $_ -Domain me.sonymusic.com | Export-Csv D:\Temp\Nash_home_shares_InAD.csv -NoTypeInformation -Append
}

# test sync
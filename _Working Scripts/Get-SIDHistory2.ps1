using namespace System.Collections.Generic
function Get-SIDHistory {
  param (
    $Domain
  )
  $UserList = [List[PSObject]]::new()
  function Convert-IntTodate {
    param ($Integer = 0)
    if ($null -eq $Integer) {
      $date = $null
    }
    else {
      $date = [datetime]::FromFileTime($Integer).ToString('g')
      if ($date.IsDaylightSavingTime) {
        $date = $date.AddHours(1)
      }
      $date
    }
  }

  $getADUserSplat = @{
    Server     = $Domain
    Properties = 'distinguishedname', 'CanonicalName', 'samAccountName', 'SID', 'sIDHistory', 'LastLogonTimeStamp', 'LastLogon', 'co', 'Country', 'Enabled'
    Filter     = "*"
  }

  try {
    $Users = Get-ADUser @getADUserSplat | Select-Object $getADUserSplat.Properties -ExpandProperty Enabled

    foreach ($User in $Users) {

      $PSObj = [PSCustomObject]@{
        DistinguishedName  = $User.DistinguishedName
        CanonicalName      = $User.CanonicalName -replace "me.sonymusic.com/Tier-2/", ""
        SamAccountName     = $User.SamAccountName
        SID                = $User.SID
        SIDHistory         = ($User.sIDHistory).Value
        LastLogonTimeStamp = (Convert-IntTodate $User.LastLogonTimeStamp)
        LastLogon          = (Convert-IntTodate $User.LastLogon)
        Co                 = $User.co
        Country            = $User.Country
        Enabled            = $User.Enabled
      }
      [void]$UserList.Add($PSObj)
    }
    return $UserList
  }
  catch {
    $Error.Message
  }
}

Get-SIDHistory -Domain "me.sonymusic.com" | Export-Csv D:\Temp\Me_SIDHistory_User.csv -NoTypeInformation
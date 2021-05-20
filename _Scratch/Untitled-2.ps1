$users = Import-CSV C:\Users\sjcny\Desktop\User_Attributes_sjcnyc.csv

foreach ($user in $users) {
  if ($user.'SamAccountName') {
    $aduser = $user.'SamAccountName'
  }
  if ($aduser) {
    Write-Host $user.SamAccountName -ForegroundColor Yellow
    $userprops = Get-Member -InputObject $user -MemberType NoteProperty
    foreach ($userprop in $userprops) {
      $propname = $userprop.name
      $propvalue = $userprop.Definition.Split("=")[1]
      if ($propvalue) {
        if ($aduser.$userprop -eq "" -or $null -eq $aduser.$userprop) {
          #splat the values into a parameters hashtable
          $parms = @{$propname = $propvalue }
          #Set-ADUser $aduser @parms
          Write-Host $parms.Values
        }
      }
    }
  }
}
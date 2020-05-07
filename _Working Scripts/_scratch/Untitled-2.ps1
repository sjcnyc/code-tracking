$users = Import-CSV C:\Users\sjcny\Desktop\User_Attributes_sjcnyc.csv

foreach ($user in $users) {
  if ($user.'SamAccountName') {
    $aduser = $true #Get-ADUser -Filter "SamAccountName -eq '$($user.samaccountname)'"
  }
  if ($aduser) {
    Write-Host "Updating active directory user: " -nonewline; Write-Host $user.SamAccountName -ForegroundColor Yellow
    $userprops = Get-Member -InputObject $user -MemberType NoteProperty
    Foreach ($userprop in $userprops) {
      $propname = $userprop.name
      $propvalue = $userprop.Definition.Split("=")[1]
      if ($propvalue) {
        if ($aduser.$userprop -eq "" -or $null -eq $aduser.$userprop) {
          #splat the values into a parameters hashtable
          $parms = @{$propname = $propvalue }
          #Set-ADUser $aduser @parms
          Write-Host $parms
        }
      }
    }
  }
}
function addAzureLicense {
  [CmdletBinding()]
  param (
    [string[]]
    $Users,

    [string]
    $skuid
  )

  foreach ($user in $users) {

    $userobj = Get-AzureADUser -SearchString $user

    if ($userobj) {

      $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
      $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

      $license.SkuId = $skuid
      $licenses.AddLicenses = $license
      Write-Verbose ("Adding license with SKU " + $skuid + " to user " + $User)
      Set-AzureADUserLicense -ObjectId $userobj.ObjectID -AssignedLicenses $licenses
    }
    else {
      Write-Error ("User " + $user + " not found.")
    }
  }
}

function removeAzureLicense {
  [cmdletbinding()]
  param (
    [string[]]
    $Users,

    [string]
    $skuid
  )

  foreach ($User In $Users) {

    try {
        
      $Userobj = Get-AzureADUser -SearchString $user

      if ($userobj) {

        $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

        $license.SkuId = $skuid

        $Licenses.RemoveLicenses = $skuid
            
        Set-AzureADUserLicense -ObjectId $userobj.objectid -AssignedLicenses $licenses
        Write-Verbose ("Removing SKU " + $skuid + " from account " + $user)

      }
    }
    catch {
      Write-Debug ("User " + $user + " not found")
    }
  }
}

function listAzureLicense ($skuid) {
  $LicensedUsers = New-Object System.Collections.Generic.List[System.Object]

  $users = Get-AzureADUser -All:$true

  foreach ($user in $users) {
    if ($user.AssignedLicenses) {
      foreach ($assignedlicense in $user.AssignedLicenses) {
        if ($assignedlicense.SkuID -eq $skuid) { 
          $LicensedUsers.Add($user)
        }
      }
    }
  }
  Write-Output $LicensedUsers
}

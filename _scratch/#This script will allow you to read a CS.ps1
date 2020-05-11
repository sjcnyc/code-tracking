$users = Import-Csv -Path "C:\Users\sjcny\Desktop\User_Attributes_sjcnyc.csv"

foreach ($user in $users) {
  $replace = @{ }
  $clear = @()

  $properties = ($user | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)

  foreach ($property in ($properties).Where{ $_ -ne "sAMAccountName" }) {

    if ($user."$property".Trim()) {
      if ($property -eq "Country" ) {
        $replace[$property] = Set-CountryHash -Country "$($user."$property".Trim())"
      }
      else {
        $replace[$property] = $user."$property".Trim()
      }
    }
    else {
      $clear += $property
    }
  }
 # $options = @{ }
 # $options['Replace'] = $replace

#  if ($clear) {
#    $options['Clear'] = $clear
#    #This runs the Set-ADUser command when there is/are blank(s) in the row
#    # Get-ADUser -Filter "sAMAccountName -eq '$($user.sAMAccountName)'" | Set-ADUser -Replace $replace -clear $clear -WhatIf
#  }
#  else {
    if ($property -eq "Country") {
      Write-Host "running Set-ADUser $($User.SamAccountName) -country $($replace["Country"])"
    }
    else {
    #This runs the Set-ADUser command when there is no value in $clear (so there are no blank values in the row)
    #Get-ADUser -Filter "sAMAccountName -eq '$($user.sAMAccountName)'" | Set-ADUser -Replace $replace -WhatIf
    Write-Host "running Set-ADUser $($User.SamAccountName) -replace $replace"
    }
 # }
  #$replace
  [environment]::NewLine
}


function Set-CountryHash {
  param (
    [string]$Country
  )

  $Countrycsvfile =
  Get-Content -Path C:\Users\sjcny\Dropbox\Development\AzureDevOps\POWERSHELL\Projects\ADUAttributeUpdater\Config\CountryCodes.json -Encoding Default | ConvertFrom-Json

  #$Country = "United States"

  $Countrycsvfile |
  ForEach-Object -Process {
    $CountryName = $_.country_name
    $CountryCode = $_.alpha_2

    if ($Country -eq "$CountryName") {
      $Country = "$CountryCode"
    }
  }
  return $Country
}
#$path = "D:\Dropbox\Development\AzureDevOps\POWERSHELL\Projects\ADUAttributeUpdater"
$path = "C:\Users\sjcny\Dropbox\Development\AzureDevOps\POWERSHELL\Projects\ADUAttributeUpdater"
$Data = Import-Csv -Path $path\Config\user.csv
$CountryJson = Get-Content -Path $path\Config\CountryCodes.json -Encoding Default | ConvertFrom-Json

try {
  foreach ($User in $Data) {
    $UserExists = $true  #(Get-ADUser -Identity $User.sAMAccountName -ErrorAction Stop).sAMAccountName
    if ($UserExists) {
      $Attributes = @{ }
      $User.psobject.properties.Where{ ![String]::IsNullOrWhiteSpace($_.Value) } |
      ForEach-Object {
        $Attributes[$_.Name] = $_.Value
        $Attributes.Remove("sAMAccountName")
        if ($Attributes.ContainsKey("Country")) {
          foreach ($Attribute in $CountryJson) {
            if ($_.Value -eq $Attribute.name) {
              $Attributes.co          = $Attribute.name
              $Attributes.c           = $Attribute.alpha_2
              $Attributes.countrycode = $Attribute.country_code
            }
          }
        }
      }
      $Attributes.Remove("Country")
      Write-Host ""
      Write-Host "Updating user: $($User.sAMAccountName)"
      #Set-ADUser -Identity $user.sAMAccountName -Replace $Attributes -WhatIf
      Write-Host ""
      $Attributes.GetEnumerator() | Sort-Object Name | Format-Table -HideTableHeaders
    }
    else {
      Write-Host "User does not exist"
    }
  }
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
  $Error[0].Exception.Message
}
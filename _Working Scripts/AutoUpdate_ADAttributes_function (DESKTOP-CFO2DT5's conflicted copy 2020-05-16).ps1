$path = "C:\Users\sjcny\Dropbox\Development\AzureDevOps\POWERSHELL\Projects\ADUAttributeUpdater"
$Data = Import-Csv -Path $path\Config\user.csv
$CountryJson = Get-Content -Path $path\Config\CountryCodes.json -Encoding Default | ConvertFrom-Json

$Data.Count

foreach ($User in $Data) {
  $Attributes = @{ }
  $User.psobject.properties.Where{ ![String]::IsNullOrWhiteSpace($_.Value) } |
  ForEach-Object {
    $Attributes[$_.Name] = $_.Value
    $Attributes.Remove("Samaccountname")
    if ($Attributes.ContainsKey("Country")) {
      $CountryJson | ForEach-Object -Process {
        if ($Attributes.Item("Country") -eq $_.name) {
          $Attributes.co          = $_.name
          $Attributes.c           = $_.alpha_2
          $Attributes.countrycode = $_.country_code
        }
      }
    }
  }
  $Attributes.Remove("Country")
  #Set-ADUser -Identity $user.SamAccountName -Replace $Attributes -WhatIf
  Write-Host ""
  Write-Host "Updating user: $($User.SamAccountName)"
  Write-Host ""
  $Attributes.GetEnumerator() | Sort-Object Name | Format-Table -HideTableHeaders
}
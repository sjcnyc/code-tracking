$path = "D:\Dropbox\Development\AzureDevOps\POWERSHELL\Projects\ADUAttributeUpdater"
$Data = Import-Csv -Path $path\Config\user.csv
$CountryJson = Get-Content -Path $path\Config\CountryCodes.json -Encoding Default | ConvertFrom-Json

$Data.Count

try {
  foreach ($User in $Data) {
    $Attributes = @{ }
    $headers = $User.psobject.properties.Where{ ![String]::IsNullOrWhiteSpace($_.Value) }
    foreach ($head in $headers) {
      $Attributes[$head.Name] = $head.Value
      $Attributes.Remove("Samaccountname")
      if ($Attributes.ContainsKey("Country")) {
        foreach ($attrib in $CountryJson) {
          if ($head.Value -eq $attrib.name) {
            Write-Host $Attributes[$head.Name]
            $Attributes.co = $attrib.name
            $Attributes.c = $attrib.alpha_2
            $Attributes.countrycode = $attrib.country_code
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
}
catch {
  $_.Error
}
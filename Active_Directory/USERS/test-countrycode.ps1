$co = @"
Afghanistan
Albania
Algeria
American Samoa
Andorra
Angola
Anguilla
Antarctica
Antigua and Barbuda
Argentina
Armenia
Aruba
Australia
Austria
Azerbaijan
Bahamas
Bahrain
Bangladesh
Barbados
Belarus
Belgium
Belize
Benin
Bermuda
Bhutan
"@ -split [environment]::NewLine

$coCsv = Import-Csv -Path C:\Temp\country-codes_New.csv
foreach ($country in $co) {

     foreach ($c in $coCsv) {
        $CountryName = $c.country
        $CountryCode = $c.countrycode

        if ($country -eq $CountryName) {
            $country_code = $CountryCode
        }
      }
      Write-Host "$($Country)'s Country-Code is : $($country_code)"
    }
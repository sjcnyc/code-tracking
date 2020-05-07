 $Countrycsvfile =
 Get-Content -Path C:\Users\sjcny\Dropbox\Development\AzureDevOps\POWERSHELL\Projects\ADUAttributeUpdater\Config\CountryCodes.json -Encoding Default | ConvertFrom-Json

$Country = "Algeria"

 $Countrycsvfile |
      ForEach-Object -Process {
        $CountryName = $_.'Country Name'
        $CountryCode = $_.Codes

        if ($Country -eq "$CountryName")
        {
          $Country = "$CountryCode"
        }
      }

      $Country
. .\O365\Invoke-All.ps1

$csv = Import-Csv C:\Temp\CloudCSV\Cloud_PFStructure2_6.csv -Encoding UTF8
$csv | Invoke-All { Get-PublicFolderClientPermission -Identity $_.Identity } -PauseInMsec 100 -EA 0 | Select-Object Identity, User, AccessRights |
Export-CSV C:\temp\PF_Batch_6.csv -Append -Encoding UTF8
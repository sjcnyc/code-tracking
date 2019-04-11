. .\O365\invokeallV2.5.ps1

$csvFile = Import-Csv C:\Temp\PF_Perm_Output_Clean\PF_Batch_1_split\PF_Batch_1_5.csv -Encoding UTF8

$csvFile  | Invoke-All { Add-PublicFolderClientPermission -Identity $_.Identity -User "Cloud-$($_.User)" -AccessRights $_.AccessRights} -ErrorAction 0
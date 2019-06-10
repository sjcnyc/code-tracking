# CSV header
# DistinguishedName

$Users = Import-Csv -Path C:\Temp\<some_csv>.csv
[byte[]]$hoursFalse = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

foreach ($User in $Users) {
  Get-ADUser -Identity $User | Set-ADUser -Replace @{logonhours = $hoursFalse }
}
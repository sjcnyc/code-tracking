@"
SamAccountName,Department,Description,GivenName,SurName
sconena,IT,IT pro,Sean,connealy
jgreen,karma,karma pro,josh,green
"@ > c:\temp\employee1.csv

$csv = Import-Csv c:\temp\employee.csv

foreach ($user in $csv[1].psobject.properties) {

  switch ($user.name) {
    GivenName { Write-Host $user.Value }
    Surname { Write-Host $user.Value }
    samaccountname { Write-Host $user.Value }
    department { Write-Host $user.Value }
    description { Write-Host $user.Value }
    Default { }
  }
}



$csv = Import-Csv "T:\110\in.csv"

$headers = $csv[0] | 
Get-Member -MemberType NoteProperty | 
Select-Object -ExpandProperty Name

ForEach ($item in $csv) {
  ForEach ($header in $headers) {
    "$header :: $($item.$header)"
  }
}
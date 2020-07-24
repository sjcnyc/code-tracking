$csv = @"
name,ip,mask,gateway
svr199,10.40.10.11,255.255.255.0,10.40.10.1
svr204,10.40.11.11,255.255.255.0,10.40.11.1
"@ | ConvertFrom-Csv

foreach ($row in $csv) {
  $hashTable = @{}
  $row.psobject.properties | ForEach-Object {
    $hashTable[$_.Name] = $_.Value
  }
  $hashTable
}
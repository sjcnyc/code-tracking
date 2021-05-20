
$users = @'
sean
bill
dean
ted
billy
john
'@ -split [environment]::NewLine

$root = @{
  records = New-Object -TypeName 'System.Collections.Generic.List[object]'
}

foreach ($user in $users) {
  $root.records.Add(@{ key = $user })
}
$root | ConvertTo-Json
$filter = (1..15 | ForEach-Object {"extensionAttribute$_ -like '*'"}) -join ' -or '
$property = 'SamAccountName', 'Name'; 1..15 | ForEach-Object {$property += "extensionAttribute$_"}
Get-ADUser -Filter $filter -Properties $property -Server 'me.sonymusic.com' | Select-Object $property -First 2
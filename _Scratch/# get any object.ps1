# get any object
$object = Get-Process -Id $pid

# try and access the PSObject
$hash = $object.PSObject.Properties.Where{ $null -ne $_.Value }.Name |
Sort-Object |
ForEach-Object { $hash = [Ordered]@{} } { $hash[$_] = $object.$_ } { $hash }

# output regularly
$object | Out-GridView -Title Regular

# output as a hash table, only non-empty properties, sorted
$hash | Out-GridView -Title Hash



# get any object
$object = Get-Process -Id $pid

# try and access the PSObject
$propNames = $object.PSObject.Properties.Where{ $null -ne $_.Value }.Name | Sort-Object
$object | Select-Object -Property $propNames


# get any object
$object = Get-Process -Id $pid

# try and access the PSObject
$object.PSObject

# find useful information
$object.PSObject.TypeNames | Out-GridView -Title Type
$object.PSObject.Properties | Out-GridView -Title Properties
$object.PSObject.Methods | Out-GridView -Title Methods
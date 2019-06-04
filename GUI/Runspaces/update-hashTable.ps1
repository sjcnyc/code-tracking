$myHash = @{}
$myHash['a'] = 1
$myHash['b'] = 2
$myHash['c'] = 3


$myHash = ($myHash.clone()).keys | % {} {$myHash[$_] = 5} {$myHash}

$myHash
$prefix = 'usazvwinf'
$filter = $prefix + '*'
#$sregex = $prefix + '\d\d\d'

$min = 101    # lowest allowable value
$max = 999

$computernames = Get-ADComputer -filter { Name -like $filter } |
Select-Object -expandProperty Name |  Sort-Object # only want name
#Where-Object { $_ -like $sregex } |     # optionally test for exactly three digits only
#Sort-Object

$i = 0
while ( $i -lt $ComputerNames.count ) {
    $test = $prefix + $min.ToString().PadLeft(3, '0')
    if ( $computernames[ $i - $min ] -ne $test) {
        break
    }
    $i++
}

if ( $i -gt $max ) {
    Write-Output "Out of numbers!"
} else {
    $NewName = $prefix + $min.ToString().PadLeft(3, '0')
    Write-Output "First free name: $NewName"
}
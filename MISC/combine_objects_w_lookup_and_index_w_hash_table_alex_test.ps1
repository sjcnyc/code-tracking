# fake objects
$numberofobjects = 5

$objects = (0..$numberofobjects) |% {
    New-Object psobject -Property @{location="NYC-$_";department="550-$_"}
    }

$lookupobjects = (0..$numberofobjects) |% {
    New-Object psobject -Property @{department="550-$_";state="New York-$_"}
    }



$hash = @{}
    foreach ($obj in $lookupobjects) {
        $hash.($obj.department) = $obj.state
    }
    foreach ($object in $objects) {
     $object |Add-Member NoteProperty -Name state -Value ($hash.($object.department)).state

}

#results
$hash


# targeting

write-host `n`n "Targeting hash 550-0 results in $($hash.'550-0')"

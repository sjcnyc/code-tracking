# generic objects
$numberofobjects = 10

# loop each of our $objects and look at our $lookupobjects to find a matching path
$objects = (0..$numberofobjects) |% {
    New-Object psobject -Property @{'Name'="object$_";'Path'="Path$_"}
}

$lookupobjects = (0..$numberofobjects) |% {
    New-Object psobject -Property @{'Path'="Path$_";'Share'="Share$_"}
}

$result =
    $hash = @{}
    # index path property with hash table
    foreach ($obj in $lookupobjects) {
        $hash.($obj.Path) = $obj.share
    }
    foreach ($object in $objects) {
     $object |Add-Member NoteProperty -Name Share -Value ($hash.($object.path)).share
    } 


# call to something in path using $hash.pathname
write-host `n`n"Direct call to value in Path: Path0 = $($hash.Path0)"

# return results of all path matches
write-host `n`n"All results:"
$result
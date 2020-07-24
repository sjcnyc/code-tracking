function ConvertFrom-Canonical {
    param(
        [Parameter(Mandatory)]
        [string]
        $canoincal
    )

    $obj = $canoincal.Replace(',', '\,').Split('/')
    [string]$DN = 'OU=' + $obj[$obj.count - 1]
    for ($i = $obj.count - 2; $i -ge 1; $i--) {
        $DN += ',OU=' + $obj[$i]
    }
    $obj[0].split('.') | ForEach-Object -Process { $DN += ',DC=' + $_}
    return $DN
}

ConvertFrom-Canonical -canoincal "me.sonymusic.com/zLegacy/USA/GBL/USR/NewSync"
$dn = "CN=pshero010,CN=Users,DC=powershell,DC=local"

function Get-SubstringOfDN {
    param(
        [string]$DN,
        [int]$splitFrom,
        [int]$splitTo
    )
    $return = ($DN.Split(",")[$splitFrom..$splitTo] -join ",")
    return $return
}

Get-SubstringOfDN -DN $dn -splitfrom 3 -splitto 2

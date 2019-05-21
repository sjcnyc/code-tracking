$dn = "CN=iPhone§12VSNH98DT6F3C0D2RODSILDH8, CN=ExchangeActiveSyncDevices, CN=Ocampo\, Jorge, OU=SonyMusicEntertainment.onmicrosoft.com, OU=Microsoft Exchange Hosted Organizations, DC=EURPR02A003, DC=prod, DC=outlook, DC=com"

function Get-SubstringOfDN {
    param(
        [string]$DN,
        [int]$splitFrom,
        [int]$splitTo
    )
    $return = ($DN.Split(",")[$splitFrom..$splitTo] -join ",")
    return $return
}

Get-SubstringOfDN -DN $dn -splitfrom 4 -splitto 10

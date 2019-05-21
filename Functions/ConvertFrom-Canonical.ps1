function ConvertFrom-Canonical {
    param([string]$canonical = (throw ('{0} is required!' -f $Canonical)))
    $obj = $canonical.Replace(',', '\,').Split('/')
    [string]$DN = 'OU=' + $obj[$obj.count - 1]
    for ($i = $obj.count - 2; $i -ge 1; $i--) {
        $DN += ',OU=' + $obj[$i]
    }
    $obj[0].split('.') | ForEach-Object -Process { $DN += ',DC=' + $_}
    return $DN
}

ConvertFrom-Canonical -canonical "me.sonymusic.com/Tier-2/STD/NA/USA/GBL/Groups"
#OU=Groups,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com

#Get-adobject -Server 'me.sonymusic.com' "OU=Groups,OU=BER,OU=DEU,OU=EU,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
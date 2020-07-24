function ConvertFrom-DN {
    param([string]$DN = (Throw "$DN is required!"))
    foreach ( $item in ($DN.replace('\,', '~').split(','))) {
        switch -regex ($item.TrimStart().Substring(0, 3)) {
            'CN=' {
                $CN = '/' + $item.replace('CN=', '')
                continue
            }
            'OU=' {
                $ou += , $item.replace('OU=', '')
                $ou += '/'
                continue
            }
            'DC=' {
                $DC += $item.replace('DC=', '')
                $DC += '.'
                continue
            }
        }
    }
    $canoincal = @()
    $canoincal = $DC.Substring(0, $DC.length - 1)
    for ($i = $ou.count; $i -ge 0; $i -- ) {
        $canoincal += $ou[$i]
    }

    # return only OU path
    #return $canoincal.Substring($DC.length - 1)

    # return full parten container path
     return $canoincal
} # end


ConvertFrom-DN -DN 'CN=abc,OU=def,OU=ghl,DC=mno'
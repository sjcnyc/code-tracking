function ConvertFrom-DN {
  param([string]$DN = (throw '$DN is required!'))
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
  $canoincal = $DC.Substring(0, $DC.length - 1)
  for ($i = $ou.count; $i -ge 0; $i -- ) {
    $canoincal += $ou[$i]
  }
  if ($CN -ne $null) {
    $canoincal += $CN.ToString().replace('~', ',')
  }
  return $canoincal
}

$sourceou = "OU=Users,OU=Deprovision,OU=STG,OU=Tier-2,DC=me,DC=sonymusic,DC=com"

ConvertFrom-DN -DN $sourceou

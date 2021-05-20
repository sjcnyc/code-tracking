using namespace System.Collections.Generic

$PSList = [List[psobject]]::new()

$getADObjectSplat = @{
  Filter     = 'ObjectClass -eq "defender-danClass"'
  SearchBase = "DC=bmg, DC=bagint, DC=com"
  Properties = '*'
}
$Tokens = ActiveDirectory\Get-ADObject @getADObjectSplat

foreach ($Token in $Tokens) {
  $PSObj = [pscustomobject]@{
    Name              = $Token.cn
    IPAddress         = $Token | Select-Object -ExpandProperty NetworkAddress
    DistinguisheNames = ($Token | Select-Object -ExpandProperty defender-dssDNs | Out-String).Trim()
  }
  [void]$PSList.Add($PSObj)
}

$PSList | Export-Csv C:\Temp\test.csv -NoTypeInformation
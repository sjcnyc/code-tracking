
$newobj = @()

$tokens = Get-QADObject -SizeLimit 0 `
  -IncludeAllProperties `
  -Type 'defender-danClass' `
  -SearchRoot 'DC=bmg,DC=bagint,DC=com'

foreach ($token in $tokens) {
  $newobj += New-Object -TypeName PSObject -Property @{
    'Comp' = $token.Name
    'IP'   = $token.networkaddress
    'DNs'  = ($token | Select-Object -ExpandProperty defender-dssDNs | Out-String).Trim()
  }
}

$newobj | Export-Csv 'c:\temp\radius_switches2.csv' -NoTypeInformation
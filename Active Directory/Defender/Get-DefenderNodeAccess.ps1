$newobj=@()

$tokens = Get-QADObject -SizeLimit 0 `
                        -IncludeAllProperties `
                        -Type 'defender-danClass' `
                        -SearchRoot 'DC=bmg,DC=bagint,DC=com'

foreach ($token in $tokens)
{
  $newobj += New-Object -TypeName PSObject -Property @{
    'Comp' = $token.cn
    'IP'   = $token.networkaddress
    'DNs'  = ($token | Select-Object -ExpandProperty defender-dssDNs | Out-String).Trim()
   }  
} 

$newobj | Export-Csv 'c:\temp\defender_stuff.csv' -NoTypeInformation
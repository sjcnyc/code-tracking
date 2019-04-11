$SourceOU = Get-QADComputer -SearchRoot 'bmg.bagint.com/USA/GBL/WST/Windows7/WWI Pilot' | Select-Object -First 50
$targetOu = 'bmg.bagint.com/USA/GBL/WST/Windows7'

foreach ($computer in $SourceOU){

  #Get-QADComputer -Identity $computer | 

  Move-QADObject -Identity $computer -NewParentContainer $targetOu -WhatIf 

}
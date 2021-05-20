$computers = @"
US-0021CC4A534E
"@-split[environment]::NewLine

foreach ($comp in $computers) {
  
  Move-QADObject -Identity $comp -NewParentContainer 'bmg.bagint.com/USA/GBL/WST/Windows7' -WhatIf 

}
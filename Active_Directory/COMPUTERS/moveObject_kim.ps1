$comps =@(
  'USL0021CCCC1179',
  'USL001C25A1623D',
  'USLF0DEF19099EA',
  'USL00247E15F7FA',
  'US-F0DEF11180B1',
  'USDD4BED9A18EA1',
  'US-0023AE8DBA51',
  'USDBC305BC833A8',
  'USD180373B2F8A2',
  'US-0019B936B474',
  'US-001C42C31EFB',
  'US-001C4245FDE7',
  'US-F0DEF124F524',
  'US-001F162E8815',
  'US-00123F2E8F1F',
  'US-0023AE5FAECF',
  'US-001C4258F0E3',
  'US-001C421A3498',
  'US-001C429ED357',
  'US-0019B9308DB3',
  'US-64809905FA70'
)

$pass = 'Happy123'

$comparry=@()
$comparry += $comps | Get-QADComputer

# Main Loop
foreach ($comp in $comparry){
  $compS = $comp | Select-Object name
  try {
    if ($comp.OSVersion -like '6.1*') {
     
        $dest = 'NYCTest/TST/WST/Windows7'
        ([adsi]"WinNT://$($compS).bmg.bagint.com/Administrator").SetPassword('Happy123')
        Write-Verbose "`tPassword Change completed for $($comp.name)" -Verbose
        }
    else {
        $dest = 'NYCTest/TST/WST/XP'
       ([adsi]"WinNT://$($compS).bmg.bagint.com/Administrator").SetPassword('Happy123')    
        Write-Verbose "`tPassword Change completed for $($comp.name)" -Verbose
        }
  }
  catch {
          Write-Verbose "Failed: $_" -Verbose
              }
  Move-QADObject -Identity $comp -To "bmg.bagint.com/$($dest)" -WhatIf
}
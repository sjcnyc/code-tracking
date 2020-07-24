$targetOu = 'bmg.bagint.com/USA/GBL/WST/Disabled'
$computers = Import-Csv 'C:\Temp\DisableComputerObjects.csv'

foreach ($computer in $computers) {
    try {
        Disable-QADComputer -Identity $computer.DistinguishedName-ErrorAction 0 #-WhatIf
        Move-QADObject -Identity $computer.DistinguishedName -To $targetOu -ErrorAction 0 #-WhatIf
        Write-Output "$($computer.name)" | Out-File C:\Temp\DisableComputerObjects.txt -Append
    }
    catch {
        Write-Output "$($Computer.Name) - $_.Exception.Message" | Out-File C:\Temp\DisableComputerObjects_error.txt -Append
    }
}
@"
USL28D24422F9C2
USL507B9D48A8DE
USL507B9D5E7F1C
USL507B9D5E7A52
ULL507B9D5E7F97
USL507B9D4B82B4
USL507B9D5E77A7
ULL507B9D5E7B4A
ULL507B9D5E76F8
ULL507B9D5E77AF
USL68F72816926F
USL507B9D5E7858
USL507B9D48A851
USL507B9D5E7A1B
ULL507B9D5E76F5
"@ -split [environment]::NewLine | ForEach-Object -Process {

    Get-ADComputer -Identity $_ | Move-ADObject -TargetPath 'OU=WWI Pilot,OU=WST,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com' -WhatIf
}
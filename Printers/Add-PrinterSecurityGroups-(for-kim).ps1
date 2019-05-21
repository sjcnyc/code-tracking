#Requires -Version 3.0 
<#
 
    .SYNOPSIS 

    .DESCRIPTION 

 
    .NOTES 
      File Name  : Add-PrinterSecurityGroups
      Author     : Sean Connealy
      Requires   : PowerShell Version 3.0 
      Date       : 4/1/2014
    .LINK 
      This script posted to: 
         http://www.github/sjcnyc
    .EXAMPLE

    .EXAMPLE

#>

import-csv 'C:\TEMP\printers.csv' | ForEach-Object {
    $name = "USA-GBL Network Printer $($_.name)"
    $description = "\\ly2\$($_.name)"
    $notes = "IP Address: $($_.ipaddress)`r`nModel: $($_.model)`r`nLocation: $($_.location)"
    $container = 'OU=25 Madison,OU=Network Printers,OU=Non-Restricted,OU=GRP,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com'
    
    New-QADGroup `
      -ParentContainer $container `
      -Name "$($name) (Primary)" `
      -samAccountName "$($name) (Primary)" `
      -GroupScope 'Global' `
      -GroupType 'Security' `
      -Description $description `
      -Notes $notes `
      -ea 0
		
    New-QADGroup `
      -ParentContainer $container `
      -Name "$($name) (Non-Primary)" `
      -samAccountName "$($name) (Non-Primary)" `
      -GroupScope 'Global' `
      -GroupType 'Security' `
      -Description $description `
      -Notes $notes `
      -ea 0
}


#25MAD-19123-SW

<#
USA-GBL Network Printer RUT-1126x (Primary)
USA-GBL Network Printer RUT-1126x (Non-Primary)

IP Address: 10.12.129.13
Model: Xerox 7970
Location: Rutherford, Floor 11, Room 1126

\\ly2\RUT-1126x

19	19123	Sony Music	25Mad - 19-123-SW
19	19207	Sony Music	25Mad - 19-207-NW
19	19228	Sony Music	25Mad - 19-228-NW
19	19323	Sony Music	25Mad - 19-323-NE
19	19413	Sony Music	25Mad - 19-413-SE
20	20115	Sony Music	25Mad - 20-115-SW
20	20209	Sony Music	25Mad - 20-209-NW
20	20315	Sony Music	25Mad - 20-315-NE
20	20403	Sony Music	25Mad - 20-403-SE
21	21115	Sony Music	25Mad - 21-115-SE
21	21219	Sony Music	25Mad - 21-219-NW
21	21303	Sony Music	25Mad - 21-303-NE
21	21412	Sony Music	25Mad - 21-412-SE
22	22117	Sony Music	25Mad - 22-117-SW
22	22207	Sony Music	25Mad - 22-207-NW
22	22403	Sony Music	25Mad - 22-403-SE
23	23115	Sony Music	25Mad - 23-115-SW
23	23303	Sony Music	25Mad - 23-303-NE
#>
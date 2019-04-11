
$usaComps = Get-QADComputer -SearchRoot 'bmg.bagint.com/USA' -SizeLimit 0 | Select-Object Name
$listComps = Import-Csv -Path C:\TEMP\ListComps.csv

Compare-Object -ReferenceObject $usaComps -DifferenceObject $listComps -Property Name -IncludeEqual | 
where-object {$_.SideIndicator -eq "=="} | Export-csv C:\Temp\Difference.csv –NoTypeInformation
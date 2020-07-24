Get-QADComputer -OSName 'Windows*Server*' -SearchScope Subtree -IncludedProperties DistinguishedName  |
    Select-Object Name, OSName, DistinguishedName, ParentContainer, @{N = 'accountStatus'; E = {if ($_.AccountIsDisabled -eq 'TRUE') {'Disabled'} else {'Enabled'}}} |
    Export-Csv c:\temp\SRV_Servers.csv -NoTypeInformation
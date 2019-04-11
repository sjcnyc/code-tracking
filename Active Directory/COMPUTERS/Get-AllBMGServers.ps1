Get-QADComputer -SizeLimit '0' -IncludedProperties name, OSServicePack, AccountIsDisabled, Description, DN,OSName, OSVersion, machineRole, ComputerRole -OSName 'Windows*Server*' | 
        Select-Object -Property name, OSServicePack, AccountIsDisabled, Description, DN,OSName, OSVersion, machineRole, ComputerRole |

        Export-Csv C:\Temp\AllServers.csv -NoTypeInformation
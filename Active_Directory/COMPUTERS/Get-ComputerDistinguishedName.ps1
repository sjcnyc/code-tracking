$CSVfILE = Import-Csv -Path 'C:\Temp\20170912-Missing SCCM Workstation Agents.csv' -Encoding UTF8

$PSArrayList = New-Object -TypeName System.Collections.ArrayList

$CSVfILE | ForEach-Object {

    try {

        $DN = Get-QADComputer $_.Name -IncludedProperties distinguishedname | Select-Object distinguishedname

        $PSObj = [pscustomobject]@{
            "Name" = $_.Name
            "Domain" = $_.Domain
            "IP" = $_IP
            "OS" = $_.OS
            "Service Pack" = $_."Service Pack"
            "Last Reported" = $_."Last Reported"
            "Qualys Version" = $_."Qualys Version"
            "Time Zone" = $_."Time Zone"
            "UTC" = $_."UTC"
            "OS version" = $_."OS version"
            "SCCM agent" = $_."SCCM agent"
            "DistinguishedName" = $DN.DistinguishedName
        }
        $null = $PSArrayList.Add($PSObj)
    }
    catch { }
}


$PSArrayList | Export-Csv "c:\temp\compDNs2.csv" -NoTypeInformation

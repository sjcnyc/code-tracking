$comps = Import-Csv -Path 'C:\temp\SCCM_comparison.csv'

$result = New-Object -TypeName System.Collections.ArrayList

foreach ($comp in $comps) {

    $compDN = (Get-ADComputer -Identity $comp.'Host Name'.Trim() -Properties DistinguishedName -EA 0).DistinguishedName

    $PSObj = [PSCustomObject]@{
        'Host Name'             = $comp.'Host Name'
        'Domain'                = $comp.Domain
        'IP Address'            = $comp.'IP Address'
        'Product Name'          = $comp.'Product Name'
        'Patch Level'           = $comp.'Patch Level'
        'Agent Cert ID'         = $comp.'Agent Cert ID'
        'Last Sysinfo (skewed)' = $comp.'Last Sysinfo (skewed)'
        'Agent Version'         = $comp.'Agent Version'
        'Timezone DST'          = $comp.'Timezone DST'
        'Timezone Standard'     = $comp.'Timezone Standard'
        'OS Bitness'            = $comp.'OS Bitness'
        'DistinguishedName'     = $compDN
    }
    $null = $result.Add($PSObj)
}

$result | Export-Csv -Path C:\temp\SCCM_comparison_DN.csv -NoTypeInformation
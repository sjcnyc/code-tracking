function Get-ComputerInfo {

    param (

        [Parameter(Mandatory)][string]$computername
    )

    try {
        foreach ($comp in $computername) {

            $opt = New-CimSessionOption -Protocol DCOM
            $sd = New-CimSession -ComputerName $comp -SessionOption $opt
            $instance = Get-CimInstance -CimSession $sd -ClassName Win32_NetworkAdapterConfiguration | Where-Object IpEnabled

            $result = New-Object System.Collections.ArrayList
        
            $object = [pscustomobject]@{

                'Computername'   = $instance.DNSHostName
                'Description'    = $instance.Description
                'DNSsearchOrder' = ($instance.DNSServerSearchOrder| Out-String).Trim()
                'IPAddress'      = ($instance.IPAddress | Out-String).Trim()
                'SerialNumber'   = (Get-CimInstance -CimSession $sd -ClassName Win32_BIOS | Select-Object -ExpandProperty SerialNumber)
            }
            $result.Add($object)
        }
        $result
    }
    catch {
        $line = $_.InvocationInfo.ScriptLineNumber
        ('Error was in Line {0}, {1}' -f ($line), $_)
    }
}

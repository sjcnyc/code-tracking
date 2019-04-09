function Test-Ping {
    param (
        [System.Object]
        $ComputerName,

        [string]
        $Domain
    )

    $ComputerName = "$($ComputerName).$($Domain)"

    $result = [pscustomobject]@{
        ComputerName = $ComputerName
        Status       = 'Unavailable'
        IPAddress    = 'Unavailable'
    }
    if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
        $result.Status    = 'Available'
        $result.IPAddress = [System.Net.Dns]::GetHostAddresses($ComputerName).IPAddressToString
    }
    return $result
}

function Get-ServersWithPing {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [string]
        $Domain,

        [string]
        $Path = "C:\Temp",

        [string]
        $FileName
    )
    Write-Verbose "Gathering Computers..."
    $GenericList = [System.Collections.Generic.List[PSObject]]::new()

    $computers = (Get-QADComputer -Service $Domain -SizeLimit '0'| Select-Object Name, OsName, ParentContainer).Where{$_.OSName -like "*Windows*Server*"}

    foreach ($computer in $computers) {
        $PingResult = Test-Ping -computername $computer.Name -Domain $Domain -ErrorAction 0
        Write-Verbose "Pinging $($Computer.Name)`tStatus:`t$($PingResult.Status)"
        $PSObject = [pscustomobject]@{
            ComputerName    = $computer.Name
            OSName          = $computer.OsName
            ParentContainer = $computer.ParentContainer
            Status          = $PingResult.Status
            IPAddress       = $PingResult.IPAddress
        }

        [void]$GenericList.Add($PSObject)
    }
    $GenericList | Export-Csv "$($Path)\$($FileName)" -NoTypeInformation
}

Get-ServersWithPing -Domain 'me.sonymusic.com' -FileName ME_SRV_0002.csv -Verbose
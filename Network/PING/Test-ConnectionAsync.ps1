Function Test-ConnectionAsync {

    [OutputType('Net.AsyncPingResult')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline = $True)]
        [string[]]$Computername = $env:COMPUTERNAME,
        [parameter()]
        [int32]$Timeout = 100,
        [parameter()]
        [Alias('Ttl')]
        [int32]$TimeToLive = 128,
        [parameter()]
        [switch]$Fragment,
        [parameter()]
        [byte[]]$Buffer = 0
    )
    Begin {

        If (-NOT $PSBoundParameters.ContainsKey('Buffer')) {
            $Buffer = 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,
            0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69
        }
        $PingOptions = New-Object System.Net.NetworkInformation.PingOptions
        $PingOptions.Ttl = $TimeToLive
        If (-NOT $PSBoundParameters.ContainsKey('Fragment')) {
            $Fragment = $False
        }
        $PingOptions.DontFragment = $Fragment
        $Computerlist = New-Object System.Collections.ArrayList
        If ($PSBoundParameters.ContainsKey('Computername')) {
            [void]$Computerlist.AddRange($Computername)
        }
        Else {
            $IsPipeline = $True
        }
    }
    Process {
        If ($IsPipeline) {
            [void]$Computerlist.Add($Computername)
        }
    }
    End {
        $Task = ForEach ($Computer in $Computername) {
            if ($Computer -as [ipaddress] -as [bool]) {
                $Computer1 = ([system.net.dns]::GetHostByAddress($Computer)).hostname
                if ($Computer1 -eq $null) {
                    $computer1 = $Computer
                }
                [pscustomobject] @{
                    Computername = $Computer1
                    Task         = (New-Object System.Net.NetworkInformation.Ping).SendPingAsync($Computer, $Timeout, $Buffer, $PingOptions)
                }
            }
            else {
                [pscustomobject] @{
                    Computername = $Computer
                    Task         = (New-Object System.Net.NetworkInformation.Ping).SendPingAsync($Computer, $Timeout, $Buffer, $PingOptions)
                }
            }
        }
        Try {
            [void][Threading.Tasks.Task]::WaitAll($Task.Task)
        }
        Catch {}
        $Task | ForEach-Object {
            If ($_.Task.IsFaulted) {
                $Result = 'Failure' #$_.Task.Exception.InnerException.InnerException.Message
                $IPAddress = $Null
            }
            Else {
                $Result = $_.Task.Result.Status
                $IPAddress = $_.task.Result.Address.ToString()
            }
            $Object = [pscustomobject]@{
                Computername = $_.Computername
                IPAddress    = $IPAddress
                Result       = $Result
            }
            $Object.pstypenames.insert(0, 'Net.AsyncPingResult')
            $Object
        }
    }
}

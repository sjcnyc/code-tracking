#requires -Modules PSHTMLTable

$style1 = '<style>
  body {color:#666666;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #666666;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#eeeeee;background-color:#666666;border:1px solid black;padding:4px;}
  td {padding:4px; border:1px solid black;}
  .odd { background-color:#ffffff; }
  .even { background-color:#E5E7E9; }
</style>'

$emailParams = @{
    to         = 'sean.connealy@sonymusic.com' #,'server.ops@sonymusic.com', 'Alex.Moldoveanu@sonymusic.com'
    from       = 'Posh Alerts poshalerts@sonymusic.com'
    subject    = "ME Server Monitor Report"
    smtpserver = 'cmailsony.servicemail24.de'
    bodyashtml = $true
}
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
                if ($null -eq $Computer1) {
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
                $Result    = 'Failure' #$_.Task.Exception.InnerException.InnerException.Message
                $IPAddress = $Null
            }
            Else {
                $Result    = $_.Task.Result.Status
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

$PSArray =  New-Object System.Collections.ArrayList

#$comps = Get-Content 'C:\Users\admsconnea\Documents\Scripts\watchips.txt'
$comps += ('OU=SRV,OU=Tier-1,DC=me,DC=sonymusic,DC=com', 'OU=SRV,OU=Tier-2,DC=me,DC=sonymusic,DC=com').ForEach( {Get-ADComputer -Server me.sonymusic.com -Searchbase $_ -Properties Name -Filter *}).Name

foreach ($comp in $comps.Name) {

    $pingtest = Test-ConnectionAsync -Computername "$($comp).me.sonymusic.com" -Timeout 100

        $PSObj = [pscustomobject]@{
            'ComputerName' = $comp
            'Result'       = $pingtest.Result

        }
    [void]$PSArray.Add($PSObj)
}

$params1 = @{
    ScriptBlock = {$args[0] -gt 0}
}

$PSArray = $PSArray | Where-Object {$_.result -ne "Success"}

$passedCount = ($PSArray | Select-Object * | Where-Object {$_.Result -eq 'Success'}).Count
$failedCount = ($PSArray | Select-Object * | Where-Object {$_.Result -eq 'Failure'}).Count
$timedCount  = ($PSArray | Select-Object * | Where-Object {$_.Result -eq 'TimedOut'}).Count
$TtlExpired  = ($PSArray | Select-Object * | Where-Object {$_.Result -eq 'TtlExpired'}).Count


$summaryTable = [PSCustomObject] @{
    "Success" = $passedCount
    "Failure" = $failedCount
    "TimeOut" = $timedCount
    'TtlExpired' = $TtlExpired
    }

    $summaryTable = $summaryTable | New-HTMLTable |
    Add-HTMLTableColor -Column "Failure" -AttrValue "background-color:#ffb3b3;" @params1 |
    Add-HTMLTableColor -Column "TimeOut" -AttrValue "background-color:#FFCC66;" @params1 |
    Add-HTMLTableColor -Column "TtlExpired" -AttrValue "background-color:#FFCC99;" @params1

    $params = @{ ScriptBlock = {$args[0] -eq $args[1]}}

    $HTML = New-HTMLHead -title "ME Server Monitor Report" -style $style1
    $HTML += "<h3>ME Server Monitor PING Results</h3>"
    
    $HTML += $summaryTable

        $HTML += "<br>"
        $HTML += $PSArray | Sort-Object result | New-HTMLTable |
        Add-HTMLTableColor -Argument 'Failure' -Column "Result" -AttrValue "background-color:#ffb3b3;" @params |
        Add-HTMLTableColor -Argument 'TimedOut' -Column "Result" -AttrValue "background-color:#FFCC66;" @params |
        Add-HTMLTableColor -Argument 'TtlExpired' -Column "Result" -AttrValue "background-color:#FFCC99;" @params
       
    $HTML += "<h4>Monitored OUs:"
    $HTML += "<h4>OU=SRV,OU=Tier-1,DC=me,DC=sonymusic,DC=com</h4>"
    $HTML += "<h4>OU=SRV,OU=Tier-2,DC=me,DC=sonymusic,DC=com</h4>"
    $HTML += "<h4>Script completed: $(Get-Date -Format G)</h4>" | Close-HTML

    Send-MailMessage @emailParams -Body ($HTML | Out-String)
function Get-UpTime
{foreach($comp in $args) {
    $wmi=Get-WmiObject -class Win32_OperatingSystem -computer $comp
    $LBTime=$wmi.ConvertToDateTime($wmi.Lastbootuptime)
    [TimeSpan]$uptime=New-TimeSpan $LBTime $(get-date)
    
    $uptimeObj = New-Object PSObject -Property @{
        Server = $comp
        Uptime = "$($uptime.Days):$($uptime.Hours):$($uptime.Minutes):$($uptime.Seconds)"
        }

    $uptimeobj | Select-Object server,uptime
  }
} 

Get-uptime USDF48E38ABF907
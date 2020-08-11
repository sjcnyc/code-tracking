[cmdletbinding(DefaultParameterSetName = "object")]

param(
  [string]
  $Computername = $env:computername,

  [string]
  $ReportTitle = "System Report",

  [ValidateScript( { $_ -ge 1 })]
  [int]$Hours = 24,

  [string]
  $Logpath = "$($env:TEMP)\SystemReport.txt",

  [switch]$Console
)

if ($computername -eq $env:computername) {
  $OK = $True
}
elseif (($computername -ne $env:computername) -and (Test-Connection -ComputerName $computername -Quiet -Count 2)) {
  $OK = $True
}

if ($OK) {
  try {
    $os = Get-WmiObject Win32_operatingSystem -ComputerName $computername -ErrorAction Stop
    $wmi = $True
  }
  catch {
    Write-Warning "WMI failed to connect to $($computername.ToUpper())"
  }
 
  if ($wmi) {
    New-Item -Path $Logpath -ItemType "file" -Force | Out-Null

    $ObjectArray = @()

    Write-Host "Preparing report for $($os.CSname)" -ForegroundColor Cyan
 
    #OS Summary
    Write-Host "...Operating System" -ForegroundColor Cyan
    $osdata = $os | Select-Object @{Name = "Computername"; Expression = { $_.CSName } },
    @{Name = "OS"; Expression = { $_.Caption } },
    @{Name = "ServicePack"; Expression = { $_.CSDVersion } },
    free*memory, totalv*, NumberOfProcesses,
    @{Name = "LastBoot"; Expression = { $_.ConvertToDateTime($_.LastBootupTime) } },
    @{Name = "Uptime"; Expression = { (Get-Date) - ($_.ConvertToDateTime($_.LastBootupTime)) } }

    #Computer system
    Write-Host "...Computer System" -ForegroundColor Cyan
    $cs = Get-WmiObject -Class Win32_Computersystem -ComputerName $computername
    $csdata = $cs | Select-Object Status, Manufacturer, Model, SystemType, Number*
 
    #services
    Write-Host "...Services" -ForegroundColor Cyan
    $wmiservices = Get-WmiObject -Class Win32_Service -ComputerName $computername
    $services = $wmiservices | Group-Object State -AsHashTable

    #get services set to auto start that are not running
    $failedAutoStart = $wmiservices | Where-Object { ($_.startmode -eq "Auto") -AND ($_.state -ne "Running") }

    #Disk Utilization
    Write-Host "...Logical Disks" -ForegroundColor Cyan
    $disks = Get-WmiObject -Class Win32_logicaldisk -Filter "Drivetype=3" -ComputerName $computername
    $diskData = $disks | Select-Object DeviceID,
    @{Name = "SizeGB"; Expression = { $_.size / 1GB -as [int] } },
    @{Name = "FreeGB"; Expression = { "{0:N2}" -f ($_.Freespace / 1GB) } },
    @{Name = "PercentFree"; Expression = { "{0:P2}" -f ($_.Freespace / $_.Size) } }

    #CPU Utilization
    Write-Host "...CPU" -ForegroundColor Cyan
    $totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
    $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
    $cpuUtil = 'CPU: ' + $cpuTime.ToString("#,0.000") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'MB (' + (104857600 * $availMem / $totalRam).ToString("#,0.0") + '%)'

    #Top 10 CPU Utilization
    Write-Host "...CPU TOP 10" -ForegroundColor Cyan
    $cputop10 = Get-WmiObject -ComputerName $Computername Win32_PerfFormattedData_PerfProc_Process | Sort-Object PercentProcessorTime -desc | Select-Object Name, PercentProcessorTime | Select-Object -First 10 | Format-Table -auto

    #Memory Utilization
    Write-Host "...Memory" -ForegroundColor Cyan
    $os = Get-CimInstance Win32_OperatingSystem
    $pctFree = [math]::Round(($os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100, 2)
    #Top 10 Memory Utilization
    Write-Host "...Memory TOP 10" -ForegroundColor Cyan
    $memTop10 = Get-WmiObject -ComputerName $Computername Win32_Process | Sort-Object WorkingSetSize -Descending | Select-Object Name, CommandLine, @{n = "Private Memory(mb)"; Expression = { [math]::round(($_.WorkingSetSize / 1mb), 2) } } | Select-Object -First 10

    if ($pctFree -ge 45) {
      $Status = "OK"
    }
    elseif ($pctFree -ge 15 ) {
      $Status = "Warning"
    }
    else {
      $Status = "Critical"
    }

    $memUtil = $os | Select-Object @{Name = "Status"; Expression = { $Status } },
    @{Name = "PctFree"; Expression = { $pctFree } },
    @{Name = "FreeGB"; Expression = { [math]::Round($_.FreePhysicalMemory / 1mb, 2) } },
    @{Name = "TotalGB"; Expression = { [int]($_.TotalVisibleMemorySize / 1mb) } }

    #Running Applications
    Write-Host "...Running Applications" -ForegroundColor Cyan
    $runningApps = Get-Process  | Group-Object -Property ProcessName |
    Format-Table Name, @{n = 'Mem(KB)'; e = { '{0:N0}' -f (($_.Group | Measure-Object WorkingSet -Sum).Sum / 1KB) }; a = 'right' } -AutoSize
 
    #NetworkAdapters
    Write-Host "...Network Adapters" -ForegroundColor Cyan
    #get NICS that have a MAC address only
    $nics = Get-WmiObject -Class Win32_NetworkAdapter -Filter "MACAddress Like '%'" -ComputerName $Computername
    $nicdata = $nics | ForEach-Object {
      $tempHash = @{Name = $_.Name; DeviceID = $_.DeviceID; AdapterType = $_.AdapterType; MACAddress = $_.MACAddress }
      #get related configuation information
      $config = $_.GetRelated() | Where-Object { $_.__CLASS -eq "Win32_NetworkadapterConfiguration" }
      #add to temporary hash
      $tempHash.Add("IPAddress", $config.IPAddress)
      $tempHash.Add("IPSubnet", $config.IPSubnet)
      $tempHash.Add("DefaultGateway", $config.DefaultIPGateway)
      $tempHash.Add("DHCP", $config.DHCPEnabled)
      #convert lease information if found
      if ($config.DHCPEnabled -AND $config.DHCPLeaseObtained) {
        $tempHash.Add("DHCPLeaseExpires", ($config.ConvertToDateTime($config.DHCPLeaseExpires)))
        $tempHash.Add("DHCPLeaseObtained", ($config.ConvertToDateTime($config.DHCPLeaseObtained)))
        $tempHash.Add("DHCPServer", $config.DHCPServer)
      }
      New-Object -TypeName PSObject -Property $tempHash
    }
    #Event log errors and warnings in the last $Hours hours
    $last = (Get-Date).AddHours(-$Hours)
    #System Log
    Write-Host "...System Event Log Error/Warning since $last" -ForegroundColor Cyan
    $syslog = Get-EventLog -LogName System -ComputerName $computername -EntryType Error, Warning -After $last
    $syslogdata = $syslog | Select-Object TimeGenerated, EventID, Source, Message
    #Application Log
    Write-Host "...Application Event Log Error/Warning since $last" -ForegroundColor Cyan
    $applog = Get-EventLog -LogName Application -ComputerName $computername -EntryType Error, Warning -After $last
    $applogdata = $applog | Select-Object TimeGenerated, EventID, Source, Message
  }

  $ObjectArray += "System Summary" + [environment]::NewLine
  $ObjectArray += ($osdata | Out-String).Trim()
  $ObjectArray += ($csdata | Out-String)
  $ObjectArray += "Failed Autostart Services"
  $ObjectArray += ($failedAutoStart | Select-Object Name, Displayname, StartMode, State | Format-Table -AutoSize | Out-String)
  $ObjectArray += "Disk Utilization"
  $ObjectArray += ($diskdata | Format-Table -AutoSize | Out-String)
  $ObjectArray += "CPU Utilization" + [environment]::NewLine
  $ObjectArray += ($cpuUtil | Out-String) + [environment]::NewLine
  $ObjectArray += "CPU Top 10 Utilization"
  $ObjectArray += ($cputop10 | Out-String) + [environment]::NewLine
  $ObjectArray += "Memory Utilization"
  $ObjectArray += ($memUtil | Out-String)
  $ObjectArray += "Memory Top 10 Utilization"
  $ObjectArray += ($memTop10 | Format-Table -AutoSize | Out-String) + [environment]::NewLine
  $ObjectArray += "Running Applications"
  $ObjectArray += ($runningApps | Out-String)
  $ObjectArray += "Network Adapters" + [environment]::NewLine
  $ObjectArray += ($nicdata | Format-List | Out-String)
  $ObjectArray += "System Event Log Summary"
  $ObjectArray += ($syslogdata | Format-List | Out-String)
  $ObjectArray += "Application Event Log Summary" + [environment]::NewLine
  $ObjectArray += ($applogdata | Format-List | Out-String) + [environment]::NewLine
  $ObjectArray += "Services"
  $ObjectArray += ($services.keys | ForEach-Object {
      $services.$_ | Select-Object Name, Displayname, StartMode, State
    } | Format-List | Out-String).TrimEnd()
  $ObjectArray += ([environment]::NewLine)
  $ObjectArray += ([environment]::NewLine)
  $ObjectArray += ("Report run {0} by {1}\{2}" -f (Get-Date), $env:USERDOMAIN, $env:USERNAME)

  foreach ($obj in $ObjectArray) {
    Add-Content -Path $Logpath -Value $obj -NoNewline
  }

  & notepad.exe $Logpath
}
else {
  #can't ping computer so fail
  Write-Warning "Failed to ping $computername"
}

[cmdletbinding(DefaultParameterSetName = "object")]

param(

  [string]
  $Computername = $env:computername,

  [ValidateScript( { $_ -ge 1 })]
  [int]$Hours = 24,

  [string]
  $LogPath = "$($env:TEMP)",

  [string]
  $LogName = "SystemReport_$((Get-Date).ToString('MMddyyyyHHmmss')).txt"
)

Import-Module CimCmdlets

$SysInfoProps = [System.Collections.Generic.List[PSObject]]@()

$versionMinimum = [Version]'5.1.99999.999'

if ($versionMinimum -lt $PSVersionTable.PSVersion) {
  "This script cannot be run on PS v6 or greater."
  "Running PowerShell $($PSVersionTable.PSVersion)."

  break
}

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
    break
  }
 
  if ($wmi) {
    New-Item -Path "$($Logpath)\$($LogName)" -ItemType "file" -Force | Out-Null

    Write-Host "Preparing report for $($os.CSname)" -ForegroundColor Cyan
 
    # OS Summary
    Write-Host "...Operating System" -ForegroundColor Cyan
    $osdata = ($os | Select-Object @{Name = "Computername"; Expression = { $_.CSName } },
      @{Name = "OS"; Expression = { $_.Caption } },
      @{Name = "ServicePack"; Expression = { $_.CSDVersion } },
      free*memory, totalv*, NumberOfProcesses,
      @{Name = "LastBoot"; Expression = { $_.ConvertToDateTime($_.LastBootupTime) } },
      @{Name = "Uptime"; Expression = { (Get-Date) - ($_.ConvertToDateTime($_.LastBootupTime)) } } | Out-String).Trim()

    # Computer system
    Write-Host "...Computer System" -ForegroundColor Cyan
    $cs = Get-WmiObject -Class Win32_Computersystem -ComputerName $computername
    $csdata = ($cs | Select-Object Status, Manufacturer, Model, SystemType, Number* | Out-String)
 
    # Services
    Write-Host "...Services" -ForegroundColor Cyan
    $wmiservices = Get-WmiObject -Class Win32_Service -ComputerName $computername
    $services = $wmiservices | Group-Object State -AsHashTable

    # Get services set to auto start that are not running
    $failedAutoStart = $wmiservices | Where-Object { ($_.startmode -eq "Auto") -AND ($_.state -ne "Running") } |
    Select-Object Name, Displayname, StartMode, State | Format-Table -AutoSize | Out-String

    # Disk Utilization
    Write-Host "...Logical Disks" -ForegroundColor Cyan
    $disks = Get-WmiObject -Class Win32_logicaldisk -Filter "Drivetype=3" -ComputerName $computername
    $diskData = ($disks | Select-Object DeviceID,
      @{Name = "SizeGB"; Expression = { $_.size / 1GB -as [int] } },
      @{Name = "FreeGB"; Expression = { "{0:N2}" -f ($_.Freespace / 1GB) } },
      @{Name = "PercentFree"; Expression = { "{0:P2}" -f ($_.Freespace / $_.Size) } } | Format-Table -AutoSize | Out-String)

    # CPU Utilization
    Write-Host "...CPU" -ForegroundColor Cyan
    $totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
    $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
    $cpuUtil = ($cpuTime.ToString("#,0.000") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'MB (' + (104857600 * $availMem / $totalRam).ToString("#,0.0") + '%)' | Out-String) + [environment]::NewLine

    # Top 10 CPU Utilization
    Write-Host "...CPU TOP 10" -ForegroundColor Cyan
    $cputop10 = (Get-WmiObject -ComputerName $Computername Win32_PerfFormattedData_PerfProc_Process | Sort-Object PercentProcessorTime -desc | Select-Object Name, PercentProcessorTime | Select-Object -First 10 | Format-Table -auto | Out-String) + [environment]::NewLine

    # Memory Utilization
    Write-Host "...Memory" -ForegroundColor Cyan
    $os = Get-CimInstance Win32_OperatingSystem
    $pctFree = [math]::Round(($os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100, 2)
    # Top 10 Memory Utilization
    Write-Host "...Memory TOP 10" -ForegroundColor Cyan
    $memTop10 = (Get-WmiObject -ComputerName $Computername Win32_Process | Sort-Object WorkingSetSize -Descending | Select-Object Name, @{n = "Private Memory(mb)"; Expression = { [math]::round(($_.WorkingSetSize / 1mb), 2) } } | Select-Object -First 10 | Format-Table -AutoSize | Out-String) + [environment]::NewLine

    if ($pctFree -ge 45) {
      $Status = "OK"
    }
    elseif ($pctFree -ge 15 ) {
      $Status = "Warning"
    }
    else {
      $Status = "Critical"
    }

    $memUtil = ($os | Select-Object @{Name = "Status"; Expression = { $Status } },
      @{Name = "PctFree"; Expression = { $pctFree } },
      @{Name = "FreeGB"; Expression = { [math]::Round($_.FreePhysicalMemory / 1mb, 2) } },
      @{Name = "TotalGB"; Expression = { [int]($_.TotalVisibleMemorySize / 1mb) } } | Out-String)

    # Running Applications
    Write-Host "...Running Applications" -ForegroundColor Cyan
    $runningApps = (Get-Process | Group-Object -Property ProcessName |
      Format-Table Name, @{n = 'Mem(KB)'; e = { '{0:N0}' -f (($_.Group | Measure-Object WorkingSet -Sum).Sum / 1KB) }; a = 'right' } -AutoSize | Out-String)

    # NetworkAdapters
    Write-Host "...Network Adapters" -ForegroundColor Cyan
    # Get NICS that have a MAC address only
    $nics = Get-WmiObject -Class Win32_NetworkAdapter -Filter "MACAddress Like '%'" -ComputerName $Computername
    $nicdata = $nics | ForEach-Object {
      $tempHash = @{Name = $_.Name; DeviceID = $_.DeviceID; AdapterType = $_.AdapterType; MACAddress = $_.MACAddress }
      # Get related configuation information
      $config = $_.GetRelated() | Where-Object { $_.__CLASS -eq "Win32_NetworkadapterConfiguration" }
      # Add to temporary hash
      $tempHash.Add("IPAddress", $config.IPAddress)
      $tempHash.Add("IPSubnet", $config.IPSubnet)
      $tempHash.Add("DefaultGateway", $config.DefaultIPGateway)
      $tempHash.Add("DHCP", $config.DHCPEnabled)
      # Convert lease information if found
      if ($config.DHCPEnabled -AND $config.DHCPLeaseObtained) {
        $tempHash.Add("DHCPLeaseExpires", ($config.ConvertToDateTime($config.DHCPLeaseExpires)))
        $tempHash.Add("DHCPLeaseObtained", ($config.ConvertToDateTime($config.DHCPLeaseObtained)))
        $tempHash.Add("DHCPServer", $config.DHCPServer)
      }
      New-Object -TypeName PSObject -Property $tempHash
    }
    $nicdata = ($nicdata | Format-List | Out-String)

    $last = (Get-Date).AddHours(-$Hours)
    # System Log
    Write-Host "...System Event Log Error/Warning since $last" -ForegroundColor Cyan
    $syslog = Get-WinEvent -ComputerName $Computername -FilterHashtable @{
      logname = "system"; level = 2, 3; starttime = $last
    } -ErrorAction 0
    $syslogdata = ($syslog | Select-Object id, timecreated, message | Format-List | Out-String)
    # Application Log
    Write-Host "...Application Event Log Error/Warning since $last" -ForegroundColor Cyan
    $applog = Get-WinEvent -ComputerName $Computername -FilterHashtable @{
      logname = "application"; level = 2, 3; starttime = $last
    } -ErrorAction 0 
    $applogdata = ($applog | Select-Object id, timecreated, message | Format-List | Out-String) + [environment]::NewLine
  }

  $SysInfoProps.Add("System Summary" + [environment]::NewLine)
  $SysInfoProps.Add($osdata)
  $SysInfoProps.Add($csdata)
  $SysInfoProps.Add("Disk Utilization")
  $SysInfoProps.Add($diskdata)
  $SysInfoProps.Add("CPU Utilization" + [environment]::NewLine)
  $SysInfoProps.Add($cpuUtil)
  $SysInfoProps.Add("CPU Top 10 Utilization")
  $SysInfoProps.Add($cputop10)
  $SysInfoProps.Add("Memory Utilization")
  $SysInfoProps.Add($memUtil)
  $SysInfoProps.Add("Memory Top 10 Utilization")
  $SysInfoProps.Add($memTop10)
  $SysInfoProps.Add("Running Applications")
  $SysInfoProps.Add($runningApps)
  $SysInfoProps.Add("Network Adapters" + [environment]::NewLine)
  $SysInfoProps.Add($nicdata)
  $SysInfoProps.Add("Failed Autostart Services")
  $SysInfoProps.Add($failedAutoStart)
  $SysInfoProps.Add("System Event Log Summary")
  $SysInfoProps.Add($syslogdata)
  $SysInfoProps.Add("Application Event Log Summary" + [environment]::NewLine)
  $SysInfoProps.Add($applogdata)
  $SysInfoProps.Add("Services")
  $SysInfoProps.Add(($services.keys | ForEach-Object {
        $services.$_ | Select-Object Name, Displayname, StartMode, State
      } | Format-List | Out-String).TrimEnd())
  $SysInfoProps.Add(([environment]::NewLine))
  $SysInfoProps.Add(([environment]::NewLine))
  $SysInfoProps.Add(("Report run {0} by {1}\{2}" -f (Get-Date), $env:USERDOMAIN, $env:USERNAME))

  foreach ($obj in $SysInfoProps) {
    Add-Content -Path "$($LogPath)\$($LogName)" -Value $obj -NoNewline
  }
  & notepad.exe "$($LogPath)\$($LogName)"
}
else {
  Write-Warning "Failed to ping $computername"
}
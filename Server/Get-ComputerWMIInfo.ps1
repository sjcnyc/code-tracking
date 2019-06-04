#requires -Version 3 -Modules ActiveDirectory, CimCmdlets
function Get-ComputerWMIInfo {
  <#
      .Synopsis
      Retrieves WMIObjects for a computer. 
      .DESCRIPTION
      Retrieves WMIObjects for a computer and formats the information for readability.
      .INPUTS
      String
      A string is recieved by the ComputerName and WMIObject parameter.
      .OUTPUTS
      Selected.Microsoft.Management.Infrastructure.CimInstance
      A selected CimInstance is returned.
      .PARAMETER ComputerName
      String of the ComputerName you are getting WMIObjects for.
      .EXAMPLE
      PS C:\> Get-ComputerWMIObject
      Gets WMI information for all objects available objects against your computer.
      .EXAMPLE
      PS C:\> Get-ComputerWMIObject -ComputerName PC01
      Gets WMI information for all objects available objects against computer PC01.
      .EXAMPLE
      PS C:\> Get-ComputerWMIObject -WMIObject BIOS,Monitor
      Gets WMI information for BIOS and Monitor against your computer.
      .EXAMPLE
      PS C:\> Get-ComputerWMIObject -ComputerName PC01,PC02 -WMIObject *
      Gets WMI information for all objects available against your PC01 and PC02.
      .NOTES
      (c) 2015 Shawn Esterman. All rights reserved.
      Written by: Shawn Esterman
      Last Updated: October 23, 2015
  #>
  [CmdletBinding(DefaultParameterSetName = 'Session',
      SupportsShouldProcess = $true,
  ConfirmImpact = 'Low')]
  Param(
    # Parameter ComputerName
    [Parameter(Position = 0,
        ValueFromPipeline = $true,
        ParameterSetname = 'Session',
    HelpMessage = 'Enter the name of the computer to query WMI information for. Defaults to localhost.')]
    [ValidateScript({ ForEach-Object -Process { Get-ADComputer -Identity $_ -Properties OperatingSystem | Where-Object -Property OperatingSystem -Like -Value '*Windows*' } })]
    [String[]] $ComputerName = $env:COMPUTERNAME,
    # Parameter WMIObject
    [Parameter(Position = 1,
        ParameterSetname = 'Session',
    HelpMessage = 'Enter the name of the WMI Object you want to retrieve. Defaults to All')]
    [ValidateSet('All','BIOS','ComputerSystem','LogicalDisk','Monitor','OperatingSystem','PhysicalMemory','Processor','SystemEnclosure','*', ignorecase = $true)]
    [String[]] $WMIObject = 'All'
  )
  Begin {
    # Create a whole bunch of arrays with variable names and expression hashtables
    $BIOSSelect = @(
      @{
        Name       = 'Class'
        Expression = {'Win32_BIOS'}
      }
      @{
        Name       = 'ComputerName'
        Expression = {$_.PSComputerName}
      }
      'Manufacturer'
      @{
        Name       = 'BIOSVersion'
        Expression = {$_.SMBIOSBIOSVersion}
      }
      'SerialNumber'
    )
    # Some of the returned information is a number that relates to a term. I put the terms in an array in order and call that item in the select variable. See below
    $ComputerSystemPowerState = @('Unknown', 'Full Power', 'Power Save - Low Power Mode', 'Power Save - Standby', 'Power Save - Unknown', 'Power Cycle', 'Power Off', 'Power Save - Warning')
    $ComputerSystemPowerSupplyState = @('Unknown', 'Other', 'Unknown', 'Safe', 'Warning', 'Critical', 'Nonrecoverable')
    $ComputerSystemThermalState = @('Unknown', 'Other', 'Unknown', 'Safe', 'Warning', 'Critical', 'Nonrecoverable')
    $ComputerSystemWakeUpType = @('Reserved', 'Other', 'Unknown', 'APM Timer', 'Modem Ring', 'LAN Remote', 'Power Switch', 'PCI PME#', 'AC Power Restored')
    $ComputerSystemSelect = @(
      @{
        Name       = 'Class'
        Expression = {'Win32_ComputerSystem'}
      }
      @{
        Name       = 'ComputerName'
        Expression = {$_.PSComputerName}
      }
      'BootupState'
      'Manufacturer'
      'Model'
      'SystemType'
      @{
        Name       = 'PowerState'
        Expression = {$ComputerSystemPowerState[$_.PowerState]}
      }
      @{
        Name       = 'PowerSupplyState'
        Expression = {$ComputerSystemPowerSupplyState[$_.PowerSupplyState]}
      }
      @{
        Name       = 'ThermalState'
        Expression = {$ComputerSystemThermalState[$_.ThermalState]}
      }
      'Domain'
      @{
        Name       = 'CurrentConsoleUser'
        Expression = {$_.UserName}
      }
      @{
        Name       = 'WakeUpType'
        Expression = {$ComputerSystemWakeUpType[$_.WakeUpType]}
      }
      'Status'
    )
    $LogicalDiskDriveType = @('Unknown', 'No Root Directory', 'Removable Disk', 'Local Disk', 'Network Drive', 'Compact Disc', 'RAM Disk')
    $LogicalDiskSelect = @(
      @{
        Name       = 'Class'
        Expression = {'Win32_LogicalDisk'}
      }
      @{
        Name       = 'ComputerName'
        Expression = {$_.PSComputerName}
      }
      'Name'
      'Compressed'
      'Description'
      @{
        Name       = 'DriveType'
        Expression = {$LogicalDiskDriveType[$_.DriveType]}
      }
      'FileSystem'
      @{
        Name       = 'FreeSpace'
        Expression = {[string](($_.FreeSpace)/1gb -as [int]) + ' GB'}
      }
      @{
        Name       = 'Size'
        Expression = {[string](($_.Size)/1gb -as [int]) + ' GB'}
      }
      'Status'
    )
    $DesktopMonitorSelect = @(
      @{
        Name       = 'Class'
        Expression = {'Win32_DesktopMonitor'}
      }
      @{
        Name       = 'ComputerName'
        Expression = {$_.PSComputerName}
      }
      'DeviceID'
      'MonitorManufacturer'
      'Name'
      @{
        Name       = 'Resolution'
        Expression = { if (($_.ScreenWidth) -and ($_.ScreenHeight)) { "$($_.ScreenWidth) x $($_.ScreenHeight)" } }
      }
      'Status'
    )
    $MonitorIDSelect = @(
      @{
        Name       = 'Class'
        Expression = {'winMonitorID'}
      }
      @{
        Name       = 'ComputerName'
        Expression = {$_.PSComputerName}
      }
      @{
        Name       = 'ManufacturerName'
        Expression = { ($_.ManufacturerName |
            ForEach-Object -Process {[char]$_} |
        Where-Object -FilterScript {$_ -match '^[d\a-z]' }) -join '' }
      }
      @{
        Name       = 'ProductCodeID'
        Expression = { ($_.ProductCodeID |
            ForEach-Object -Process {[char]$_} |
        Where-Object -FilterScript {$_ -match '^[d\a-z]' }) -join '' }
      }
      @{
        Name       = 'SerialNumberID'
        Expression = { ($_.SerialNumberID |
            ForEach-Object -Process {[char]$_} |
        Where-Object -FilterScript {$_ -match '^[d\a-z]' }) -join '' }
      }
      @{
        Name       = 'FriendlyName'
        Expression = { ($_.FriendlyName |
            ForEach-Object -Process {[char]$_} |
        Where-Object -FilterScript {$_ -match '^[d\a-z]' }) -join '' }
      }
      @{
        Name       = 'ManufactureDate'
        Expression = { if (($_.WeekOfManufacture) -and ($_.WeekOfManufacture)) { (([DateTime]"01/01/$($_.YearOfManufacture)").AddDays(($_.WeekOfManufacture)*7)).ToString('Y') } }
      }
    )
    $OperatingSystemSelect = @(
      @{
        Name       = 'Class'
        Expression = {'Win32_OperatingSystem'}
      }
      @{
        Name       = 'ComputerName'
        Expression = {$_.PSComputerName}
      }
      @{
        Name       = 'OSName'
        Expression = {$_.Caption}
      }
      'OSArchitecture'
      @{
        Name       = 'ServicePack'
        Expression = {$_.CSDVersion}
      }
      'BuildNumber'
      'Version'
      @{
        Name       = 'InstallDate'
        Expression = {$_.ConvertToDateTime($_.InstallDate)}
      }, 
      @{
        Name       = 'LastBootUpTime'
        Expression = {$_.ConvertToDateTime($_.LastBootUpTime)}
      }
      'Status'
    )
    $PhysicalMemoryFormFactor = @('Unknown', 'Other', 'DRAM', 'Synchronous DRAM', 'Cache DRAM', 'EDO', 'EDRAM', 'VRAM', 'SRAM', 'RAM', 'ROM', 'Flash', 'EEPROM', 'FEPROM', 'EPROM', 'CDRAM', '3DRAM', 'SDRAM', 'SGRAM', 'RDRAM', 'DDR', 'DDR2', 'DDR2', 'DDR2 FB-DIMM', 'DDR3', 'FBD2' )
    $PhysicalMemorySelect = @(
      @{
        Name       = 'Class'
        Expression = {'Win32_PhysicalMemory'}
      }
      @{
        Name       = 'ComputerName'
        Expression = {$_.PSComputerName}
      }
      @{
        Name       = 'Bank'
        Expression = {$_.BankLabel}
      }
      @{
        Name       = 'Dimm'
        Expression = {$_.DeviceLocator}
      }
      'Manufacturer'
      'PartNumber'
      'SerialNumber'
      @{
        Name       = 'FormFactor'
        Expression = {$PhysicalMemoryFormFactor[$_.FormFactor]}
      }
      @{
        Name       = 'Size'
        Expression = {[string](($_.Capacity)/1gb) + ' GB'}
      }
      'Speed'
      'DataWidth'
      'Status'
    )
    $ProcessorArchitecture = @('x86', 'MIPS', 'Alpha', 'PowerPC', 'unknown', 'ARM', 'Itanium-based systems', 'unknown', 'unknown', 'x64')
    $ProcessorAvailability = @('Unknown', 'Other', 'Unknown', 'Running or Full Power', 'Warning', 'In Test', 'Not Applicable', 'Power Off', 'Off Line', 'Off Duty', 'Degraded', 'Not Installed', 'Install Error', 'Power Save - Unknown', 'Power Save - Low Power Mode', 'Power Save - Standby', 'Power Cycle', 'Power Save - Warning')
    $ProcessorCPUStatus = @('Unknown', 'CPU Enabled', 'CPU Disabled by User via BIOS Setup', 'CPU Disabled by BIOS (POST Error)', 'CPU Is Idle', 'Reserved', 'Reserved', 'Other')
    $ProcessorSelect = @(
      @{
        Name       = 'Class'
        Expression = {'Win32_Processor'}
      }
      @{
        Name       = 'ComputerName'
        Expression = {$_.PSComputerName}
      }
      'DeviceID'
      'Description'
      'Name'
      'Manufacturer'
      'NumberOfCores'
      'NumberOfLogicalProcessors'
      'AddressWidth'
      @{
        Name       = 'Architecture'
        Expression = {$ProcessorArchitecture[$_.Architecture]}
      }, 
      @{
        Name       = 'Availability'
        Expression = {$ProcessorAvailability[$_.Availability]}
      }, 
      'LoadPercentage'
      @{
        Name       = 'CPU Status'
        Expression = {$ProcessorCPUStatus[$_.CpuStatus]}
      }
      'Status'
    )
    $SystemEnclosureChassisTypes = @('Unknown', 'Other', 'Unknown', 'Desktop', 'Low Profile Desktop', 'Pizza Box', 'Mini Tower', 'Tower', 'Portable', 'Laptop', 'Notebook', 'Hand Held', 'Docking Station', 'All in One', 'Sub Notebook', 'Space-Saving', 'Lunch Box', 'Main System Chassis', 'Expansion Chassis', 'SubChassis', 'Bus Expansion Chassis', 'Peripheral Chassis', 'Storage Chassis', 'Rack Mount Chassis', 'Sealed-Case PC')
    $SystemEnclosureSelect = @(
      @{
        Name       = 'Class'
        Expression = {'Win32_SystemEnclosure'}
      }
      @{
        Name       = 'ComputerName'
        Expression = {$_.PSComputerName}
      }
      'Manufacturer'
      'SerialNumber'
      @{
        Name       = 'ChassisType'
        Expression = {$SystemEnclosureChassisTypes[$_.ChassisTypes]}
      }
    )
  }
  Process {
    # Regex doesn't work with a asterisk using my switch below. So if the WMIObject contains a *, set it to 'All'
    if ( $WMIObject -contains '*' ) { $WMIObject = 'All' }

    foreach ($Computer in $ComputerName) {
      if ( $pscmdlet.ShouldProcess( $Computer, 'Getting WMI information' ) ) {
        if ( Test-Connection -ComputerName $Computer -Count 1 -TimeToLive 20 -Quiet ) {
          $Objects = @() # Collect information here
          $Splat = @{
            ComputerName = $Computer
            ErrorAction  = 'SilentlyContinue'
          } # Common stuff ( Get-Help about_Splatting )
          $Objects = Switch -regex ( $WMIObject ) {
            'BIOS|All'            { Get-CimInstance @Splat -ClassName Win32_BIOS                       | Select-Object -Property $BIOSSelect            }
            'ComputerSystem|All'  { Get-CimInstance @Splat -ClassName Win32_ComputerSystem             | Select-Object -Property $ComputerSystemSelect  }
            'LogicalDisk|All'     { Get-CimInstance @Splat -ClassName Win32_logicaldisk                | Select-Object -Property $LogicalDiskSelect     }
            'Monitor|All'         {
              Get-CimInstance @Splat -ClassName Win32_DesktopMonitor             | Select-Object -Property $DesktopMonitorSelect
              Get-CimInstance @Splat -ClassName wmiMonitorID -Namespace root\wmi | Select-Object -Property $MonitorIDSelect
            }
            'OperatingSystem|All' { Get-CimInstance @Splat -ClassName Win32_OperatingSystem            | Select-Object -Property $OperatingSystemSelect }
            'PhysicalMemory|All'  { Get-CimInstance @Splat -ClassName Win32_PhysicalMemory             | Select-Object -Property $PhysicalMemorySelect  }
            'Processor|All'       { Get-CimInstance @Splat -ClassName Win32_Processor                  | Select-Object -Property $ProcessorSelect       }
            'SystemEnclosure|All' { Get-CimInstance @Splat -ClassName Win32_SystemEnclosure            | Select-Object -Property $SystemEnclosureSelect }
          } # If you have multiple objects in the WMIObject array, it will do all that apply

          # Return information collected
          Write-Output -InputObject $Objects
        } else {Write-Warning -Message "Could not reach $Computer. Make sure it is reachable on the network."}
      }
    }
  }
  End {}
} # End function Get-ComputerWMIInfo
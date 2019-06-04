function Get-SystemInfo {
    param(
        $ComputerName = $env:ComputerName
    )

    $header =
    @"
Hostname
OSName
OSVersion
OSManufacturer
OSConfig
Buildtype
RegisteredOwner
RegisteredOrganization
ProductID
InstallDate
StartTime
Manufacturer
Model
Type
Processor
BIOSVersion
WindowsFolder
SystemFolder
StartDevice
Culture
UICulture
TimeZone
PhysicalMemory
AvailablePhysicalMemory
MaxVirtualMemory
AvailableVirtualMemory
UsedVirtualMemory
PagingFile
Domain
LogonServer
Hotfix
NetworkAdapter
"@ -split [environment]::NewLine
  
    systeminfo.exe /FO CSV /S $ComputerName| Select-Object -Skip 1| ConvertFrom-CSV -Header $header

}


Get-SystemInfo -ComputerName localhost
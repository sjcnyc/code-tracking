function script:CreatePrinterPort 
{ 
  Param ( 
    [Parameter(Mandatory)][string]$IPAddress 
  ) 
  $port = [wmiclass]'Win32_TcpIpPrinterPort' 
  $newPort = $port.CreateInstance() 
  $newPort.Name = "IP_$IPAddress" 
  $newPort.SNMPEnabled = $false 
  $newPort.Protocol = 1 
  $newPort.HostAddress = $IPAddress 
  Write-Host -Object "Creating Port $IPAddress" -ForegroundColor 'green' 
  $newPort.Put() 
} 

createprinterport -ipaddress '10.10.10.101' -portname 'PortName1'

function script:CreatePrinter 
{ 
  Param ( 
    [Parameter(Mandatory)][string]$PrinterName, 
    [Parameter(Mandatory)][string]$DriverName, 
    [Parameter(Mandatory)][string]$Portname, 
    [Parameter(Mandatory)][string]$Location, 
    [Parameter(Mandatory)][string]$Comment 
  ) 
  $print                 = (Get-WmiObject -List -Class Win32_Printer)
  $newprinter            = $print.createInstance()
  $newprinter.PortName   = "$Portname"
  $newprinter.Drivername = $DriverName
  $newprinter.DeviceID   = $PrinterName
  $newprinter.Shared     = $true
  $newprinter.Published  = $true
  $newprinter.Sharename  = $PrinterName
  $newprinter.Location   = $Location
  $newprinter.Comment    = $Comment
  Write-Host -Object "Creating Printer $PrinterName" -ForegroundColor 'green' 
  $newprinter.Put() 
} 

CreatePrinter  -PrinterName 'Printer_1' -DriverName 'HP 910' -PortName 'PortName1' -Location 'Deck 1' -Comment 'If you printed here you would be printing now'
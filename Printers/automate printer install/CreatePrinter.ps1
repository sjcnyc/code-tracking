# Create Network Printer from CSV file script
# 3/11/2011
# usage: csv file with headers: printserver,driver,portname,sharename,location,comments,printername

function CreatePrinterPort {
  $server           = $args[0]
  $port             = ([WMICLASS]"\\$server\ROOT\cimv2:Win32_TCPIPPrinterPort").createInstance()
  $port.Name        = $args[1]
  $port.SNMPEnabled = $false
  $port.Protocol    = 1
  $port.HostAddress = $args[2]
  $port.Put()
}

function CreatePrinter {
  $server           = $args[0]
  $print            = ([WMICLASS]"\\$server\ROOT\cimv2:Win32_Printer").createInstance()
  $print.drivername = $args[1]
  $print.PortName   = $args[2]
  $print.Shared     = $true
  $print.published  = $true
  $print.Sharename  = $args[3]
  $print.Location   = $args[4]
  $print.Comment    = $args[5]
  $print.DeviceID   = $args[6]
  $print.Put()
}
 
$printers = Import-Csv "C:\Users\sconnea\Documents\DEVELOPMENT\_POWERSHELL\automate printer install\printers.csv"
 
foreach ($printer in $printers) {
  CreatePrinterPort $printer.Printserver $printer.Portname $printer.IPAddress
  CreatePrinter $printer.Printserver $printer.Driver $printer.Portname $printer.Sharename $printer.Location $printer.Comment $printer.Printername
}
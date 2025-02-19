﻿#Requires -Version 3.0 
<# 
    .SYNOPSIS 


    .DESCRIPTION 

 
    .NOTES 
        File Name  : Get-PrinterInverntory-XLS
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/3/2014

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

    .EXAMPLE

#>

$Printserver ='ny1'

# Create new Excel workbook
$Excel = new-Object -comobject Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)
$Sheet.Cells.Item(1,1) = 'Printer Name'
$Sheet.Cells.Item(1,2) = 'Location'
$Sheet.Cells.Item(1,3) = 'Comment'
$Sheet.Cells.Item(1,4) = 'IP Address'
$Sheet.Cells.Item(1,5) = 'Driver Name'
$Sheet.Cells.Item(1,6) = 'Shared'
$Sheet.Cells.Item(1,7) = 'Share Name'
$intRow = 2
$WorkBook = $Sheet.UsedRange
$WorkBook.Font.Bold = $True

# Get printer information
$Printers = Get-WMIObject Win32_Printer -computername $Printserver
foreach ($Printer in $Printers)
{
  $Sheet.Cells.Item($intRow, 1) = $Printer.Name
  $Sheet.Cells.Item($intRow, 2) = $Printer.Location
  $Sheet.Cells.Item($intRow, 3) = $Printer.Comment
  $Ports = Get-WmiObject Win32_TcpIpPrinterPort -computername $Printserver
  foreach ($Port in $Ports)
  {
    if ($Port.Name -eq $Printer.PortName)
    {
      $Sheet.Cells.Item($intRow, 4) = $Port.HostAddress
    }
  }
  $Sheet.Cells.Item($intRow, 5) = $Printer.DriverName
  $Sheet.Cells.Item($intRow, 6) = $Printer.Shared
  $Sheet.Cells.Item($intRow, 7) = $Printer.ShareName
  $intRow = $intRow + 1
}

$WorkBook.EntireColumn.AutoFit()
$intRow = $intRow + 1
$Sheet.Cells.Item($intRow,1).Font.Bold = $True
$Sheet.Cells.Item($intRow,1) = "Print server inventory for Print server: $Printserver"
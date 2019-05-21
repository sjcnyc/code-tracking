#Requires -Version 3.0 
<# 
    .SYNOPSIS 
    Function to get print server inventory

    .DESCRIPTION 
    Function to get print server inventory
 
    .NOTES 
    File Name  : Get-PrintServerInventory
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 4/3/2014

    .LINK 
    This script posted to: http://www.github/sjcnyc

    .EXAMPLE
    Get-PrintServerInventory -printserver ly2

    .EXAMPLE

#>

function Get-PrintServerInventory1  
{
  param
  (
    [string]$printserver,
    [switch]$export
  )

  $Printers = Get-WmiObject -Class Win32_Printer -ComputerName $printserver

  foreach ($printer in $Printers) 
  {
    if ($printer.Name -notlike 'Microsoft XPS*')
    {
      If ($printer.PortName -notlike '*\*')
      {
        $Ports = Get-WmiObject -Class Win32_TcpIpPrinterPort -Filter "name = '$($printer.Portname)'" -ComputerName $printserver
        ForEach ($Port in $Ports)
        {
          $ipaddress = $Port.HostAddress
        }
      }

      $result = New-Object System.Collections.ArrayList

      $obj = [pscustomobject]@{
        'Server'    = $printer.SystemName
        'PrinterName' = $printer.Name
        'Location'  = $printer.Location
        'Comment'   = $printer.Comment
        'Shared'    = $printer.Shared
        'Sharename' = $printer.ShareName
        'DriverName' = $printer.DriverName
        'IPAddress' = $ipaddress
      }
      [void]$result.Add($obj)
    }
  }
  if ($export)
  {
    $result  | Export-Csv -Path 'c:\temp\printers2.csv' -NoTypeInformation
  }
  else 
  {
    $result |
    Sort-Object -Property PrinterName |
    Format-Table -AutoSize
  }
}

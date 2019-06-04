#Requires -Version 1 
<# 
    .SYNOPSIS
    Gets boot LastBootUpTime

    .DESCRIPTION
    Gets boot LastBootUpTime using Win32_OperatingSystem Class

    .NOTES 
    File Name  : Get-LastBootUpTime.ps1
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 12/3/2015

    .LINK 
    This script posted to: http://www.github/sjcnyc

    .EXAMPLE
    Get-BootTime -computer ny1
    ComputerName LastBootTime
    ------------ ------------
    ny1          11/20/2015 10:56:45 PM
#>

$computers = 'usnycpwfs01'

function Get-BootTime  {
  param
  (
    [Object]
    $computer
  ) 
  
  $resultObj = [pscustomobject] @{
    'ComputerName' = $computer
   # 'LastBootTime' = [Management.ManagementDateTimeConverter]::ToDateTime( `
   # (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer | Select-Object -ExpandProperty LastBootUpTime))
    'LastBootUpTime' = Get-CimInstance Win32_OperatingSystem  | Select-Object -ExpandProperty LastBootUpTime
  }
  $resultObj
}

# List of computers from text file
# $computers = Get-Content -Path c:\temp\computers.text
# List of computers from CSV file
# $computers = Import-Csv -Path c:\temp\computers.csv
# List of computers from AD using Microsoft AD Module
# $computers = Get-ADComputer -SearchBase 'OU=WST,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com' -Filter * | Select-Object Name
# List of computers from AD using Quest AD Management Shell
# $computers = Get-QADComputer -SizeLimit 0 -SearchRoot 'bmg.bagint.com/USA/GBL/WST' | Select-Object Name

# Loop results, call Get-BootTime function.  Remove # after $computer to export to csv file
Foreach ($computer in $computers) {Get-BootTime -computer $computer #| Export-Csv c:\temp\lastBootTime.csv -NoTypeInformation -Append
}
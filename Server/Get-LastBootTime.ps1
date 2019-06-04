#Requires -Version 3.0 
<# 
    .SYNOPSIS

    .DESCRIPTION
 
    .NOTES 
        File Name  : Get-LastBootTime
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 5/12/2015

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

#>

function Get-LastBootTime {
param(
  [string]$computerName
  )
  
  Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computerName | Select-Object csname, lastbootuptime
  
  }

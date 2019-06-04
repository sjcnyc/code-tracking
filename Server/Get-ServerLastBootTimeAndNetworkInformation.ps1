#Requires -Version 2.0 
<# 
    .SYNOPSIS
        Get server LastBootTime and Network Information
    .DESCRIPTION
 
    .NOTES 
        File Name  : Get-ServerLastBootTimeAndNetworkInformation.ps1
        Author     : Sean Connealy
        Requires   : PowerShell Version 2.0 
        Date       : 7/8/2015

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE
#>

Function Get-Uptime {
  [cmdletbinding()]
  param (
    [parameter(mandatory = $true,position = 0)]$comp
  )
  begin {}
  process {

    ForEach-Object -Process {
      $System  = (Get-WmiObject  -Class Win32_OperatingSystem -ComputerName $comp)
      $IPaddress = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $comp |
      Where-Object -FilterScript { $_.IPEnabled -eq $true -and $_.DHCPEnabled -eq $False})
      foreach ($ip in $IPaddress)
      {
        if ( Test-Connection -ComputerName $comp -Count 1 -ea 0 ) 
        {
          $Bootup = $System.LastBootUpTime
          $LastBootUpTime = $System.ConvertToDateTime($System.LastBootUpTime)
          $IsDHCPEnabled = $False

          if ($ip.DHCPEnabled) {$IsDHCPEnabled = $true}

          $NewObjProps = [pscustomobject]@{
            ComputerName   = $comp.ToUpper()
            IPaddress      = $ip.ipaddress[0]
            SubnetMask     = $ip.ipsubnet[0]
            DefaultGateway = $ip.DefaultIPGateway[0]
            DNSServers     = (($ip.DNSServerSearchOrder)| Out-String).Trim()
            DHCP           = $IsDHCPEnabled
            LastBootUpTime = $LastBootUpTime
          }
        }
      }
      $NewObjProps
    }
  }
  end {}
}

Get-Uptime -comp ny1
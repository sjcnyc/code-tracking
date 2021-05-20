function Set-DnsServerIpAddress {
  param(
    [string] $ComputerName,
    [string] $NicName,
    [string] $IpAddresses
  )
  if (Test-Connection -ComputerName $ComputerName -Count 2 -Quiet) {
    Invoke-Command -ComputerName $ComputerName -ScriptBlock { param ($ComputerName, $IpAddresses)
      Write-Output "Setting on $ComputerName on interface $NicName a new set of DNS Servers $IpAddresses"
      $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -comp $comp | Where-Object {$_.IPEnabled -eq 'TRUE'}
        foreach ($NIC in $NICs) {
        Set-DnsClientServerAddress -InterfaceAlias $NicName -ServerAddresses $IpAddresses
        }
    } -ArgumentList $ComputerName, $IpAddresses

  }
  else {
    write-host "Can't access $ComputerName. Computer is not online."
  }
}

Set-DnsServerIpAddress -ComputerName "" -

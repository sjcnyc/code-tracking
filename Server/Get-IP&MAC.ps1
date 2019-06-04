function Get-IPandMAC {

  param($ComputerName)
  $nicname = @{
      Name = 'NICname'
      Expression = { ($_.Caption -split '] ')[-1] }
  }
  
  $ipV4 = @{
    Name = 'IPv4'
    Expression = { ($_.IPAddress -like '*.*.*.*') -join ',' }
  }

  $ipV6 = @{
    Name = 'IPv6'
    Expression = { ($_.IPAddress -like '*::*') -join ',' }
  }

  Get-WmiObject -Class Win32_NetworkAdapterConfiguration @PSBoundParameters |
  Select-Object -Property $nicname, $ipv4, $ipv6, MacAddress |
  Where-Object { $_.MacAddress -ne $null }
}

Get-IPandMAC -ComputerName ny1
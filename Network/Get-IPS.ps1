function get-ips 
{
  Param([string]$computername = $env:computername)

  [regex]$ip4 = '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

  Get-WmiObject -Class win32_networkadapterconfiguration -Filter "IPEnabled='True'" -ComputerName $computername | 
  Select-Object -Property DNSHostname, Index, Description, @{
    Name       = 'IPv4'
    Expression = {
      $_.IPAddress -match $ip4
    }
  }, 
  @{
    Name       = 'IPv6'
    Expression = {
      $_.IPAddress -notmatch $ip4
    }
  }, MACAddress
}

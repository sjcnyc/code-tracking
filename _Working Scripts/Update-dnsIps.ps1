function Update-DnsIps {
  param (
    [string]
    $ComputerName,

    [array]
    $DnsIps
  )

  if (Test-Connection $ComputerName -Count 2 -Quiet) {
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
      Get-NetAdapter | Where-Object status -eq 'up' | ForEach-Object {
        Set-DNSClientServerAddress –interfaceIndex $_.ifIndex –ServerAddresses ($DnsIps) -Verbose
      }
    }
  }
  else {
    Write-Output "Unable to connect to '$computer' - $(get-date)"
  }
}

Update-DnsIps -ComputerName "APSYDVWJMP102" -DnsIps "ips", "ips"
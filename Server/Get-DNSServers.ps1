function Get-DNSServers  {
  param
  (
    [Parameter(Mandatory)][String]
    $computer
  )
  try {
    $Networks = Get-WmiObject -Class Win32_NetworkAdapterConfiguration `
     -Filter IPEnabled=TRUE -ComputerName $Computer -ErrorAction Stop
  } 
  catch {
    Write-Verbose "Failed to Query $Computer. Error details: $_"
    continue
  }

  foreach($Network in $Networks) {
    $DNSServers = $Network.DNSServerSearchOrder
    $NetworkName = $Network.Description
    if(!$DNSServers) {
      $PrimaryDNSServer = 'Notset'
      $SecondaryDNSServer = 'Notset'
    } elseif($DNSServers.count -eq 1) {
      $PrimaryDNSServer = $DNSServers[0]
      $SecondaryDNSServer = 'Notset'
    } else {
      $PrimaryDNSServer = $DNSServers[0]
      $SecondaryDNSServer = $DNSServers[1]
    }

    $result = New-Object System.Collections.ArrayList

    $OutputObj = [pscustomobject] @{
      'ComputerName' = $Computer.ToUpper()
      'PrimaryDNSServers' = $PrimaryDNSServer
      'SecondaryDNSServers' = $SecondaryDNSServer
      'IsDHCPEnabled' = $IsDHCPEnabled
      'NetworkName' = $NetworkName
    }

    $result.Add($OutputObj)
  }
  $result
}
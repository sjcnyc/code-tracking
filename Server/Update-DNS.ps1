function Update-DNS {
  [cmdletBinding(SupportsShouldProcess = $true)]
  param(
    [ValidateSet("ComputerName", "ComputerNames")]
    [object]
    $Computer,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)][system.array]$DNSServers
  )
  process {
    Clear-Host
    $path = Get-ScriptDirectory

    switch ($Computer) {
      ComputerName  { $Content = $Computer }
      ComputerNames { Get-Content $computers }
    }
    foreach ($comp in $content) {
      if (Test-Connection -ComputerName $comp -count 1 -Quiet) {
        Write-Host "Updating DNS entries for: $comp" -NoNewline
        $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -comp $comp | Where-Object {$_.IPEnabled -eq 'TRUE'}
        foreach ($NIC in $NICs) {
          $NIC.SetDNSServerSearchOrder($DNSServers) | Out-Null
        }
        Write-Host " to: $($DNSServers) - [ OK ]"
      }
      else {
        Write-Host "Failed to change DNS for: $comp"
      }
    }
  }
}

Update-DNS -Computer "computername" -DNSServers "dnsip","dnsip"
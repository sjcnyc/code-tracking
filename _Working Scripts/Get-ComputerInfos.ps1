Function Get-ComputerInfos() {
  $ipinfo = Invoke-RestMethod http://ipinfo.io/json
  [System.Collections.Generic.List[psobject]]$Results = Get-NetIPAddress |
  Where-Object { $_.AddressState -EQ 'Preferred' -and $null -ne $_.IPAddress -and $_.IPAddress -ne '127.0.0.1' } |
  Sort-Object -Property PrefixOrigin -Descending |
  Select-Object IPAddress, InterfaceAlias
  $Results.Add(([PSCustomObject]@{'IPAddress' = $ipinfo.ip ; 'InterfaceAlias' = 'External IP' }))


  $disk = Get-WmiObject Win32_LogicalDisk | Where-Object DriveType -EQ 3

  $DiskOutput = $disk | Select-Object DeviceID,
  @{n = 'Free %'; e = { [Math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } },
  @{n = 'Free GB'; e = { [Math]::Round(($_.FreeSpace / 1gb), 2) } },
  @{n = 'Total Space'; e = { [Math]::Round(($_.Size / 1gb), 2) } }

  return @"
Computer name:          $($env:COMPUTERNAME)
Domain:                 $($env:USERDOMAIN)
Username:               $($env:USERNAME)
Version:                $([Environment]::OSVersion.VersionString)
PSVersion:              $($PSVersionTable.PSVersion)
$($DiskOutput | Out-String)
$($Results | Out-String)
"@
}
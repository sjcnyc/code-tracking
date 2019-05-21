Function Backup-DHCP {
  [cmdletBinding(SupportsShouldProcess=$True)]
  param (
    [Parameter(Mandatory=$true, ValueFromPipeline = $true)][array]$srvlist,
    [Parameter(Mandatory=$false, ValueFromPipeline= $true)][switch]$all,
    [Parameter(Mandatory=$false, ValueFromPipeline= $true)][switch]$config,
    [Parameter(Mandatory=$false, ValueFromPipeline= $true)][switch]$scope
  )
  
  $srvlist | ForEach-Object {
    $srv = $_
    $srvName = nslookup $srv |Where-Object {$_ -like 'name*'} |% {$_.split(':')[1].trim()} |% {$_.split('.')[0].trim()}    
    $dow = (Get-Date).DayOfWeek  
    $rtDir = "\\192.168.34.86\c$\temp"
    $bkDir = "$($rtDir)\DHCP-Backup-$srvName"
    if (Test-Path $bkDir) {}
    else { New-Item -path $rtDir -name "DHCP-Backup-$($srvName)" -type directory
    }
    if ($all) {
      #backup DHCP
      Invoke-Command -Scriptblock {netsh dhcp server export "$($bkDir)\$dow-DHCP-$($srvName)-NetshExport.dat" all} | out-null
    }
    if ($config) {
      #backup the config
      netsh dhcp server $srv dump > "$($bkDir)\$($dow)-DHCP-$($srvName)-Config.cfg"
    }
    if ($scope) {
      #backup scope list
      netsh dhcp server $srv show scope > "$($bkDir)\$($dow)-DHCP-$($srvName)-ScopeList.txt"
      $scopeList = Get-Content "$($bkDir)\$($dow)-DHCP-$($srvName)-ScopeList.txt"
      $scopeCount = $scopeList.Count
      if ($scopeCount -le 3) {
        Write-Host 'No scope(s) dude!'
      }
      else {
        $scopeWork = $scopeList | Select-Object -Skip 5 | Select-Object -First ($scopeCount -8) | 
        ForEach-Object {($_ -split '\s+',3)[1]}   
        #get info from each scope
        $scopeWork | 
        ForEach-Object {                
          netsh dhcp server $srv scope $_ dump > "$($bkDir)\$($dow)-DHCP-$($srvName)-Scope-$($_)-Config.txt"
        }
      }
    }
  }
}
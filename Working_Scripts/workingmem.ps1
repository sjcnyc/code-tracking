Write-Host "...Running Applications" -ForegroundColor Cyan
$runningApps = (Get-Process | Group-Object -Property ProcessName |
  Format-Table Name, @{n = 'Mem(KB)'; e = { '{0:N0}' -f (($_.Group | Measure-Object WorkingSet -Sum).Sum / 1KB) }; a = 'right' } -AutoSize | Out-String)

$runningApps


$mem = Get-Process |Sort-Object WorkingSetSize -Descending | Group-Object -Property ProcessName |

Select-Object Name, @{N = "Mem(KB)"; E = { '{0:N0}' -f (($_.Group |sort-object WorkingSet -Descending| Measure-Object WorkingSet -Sum).Sum / 1KB)} }


Get-Process | Sort-Object WorkingSet64 -Descending -Unique  | Group-Object -Property Name |

Select-Object Name, @{Name = 'WorkingSet'; Expression = { ($_.WorkingSet64 / 1KB)}}
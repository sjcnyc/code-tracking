filter Get-CapacitySize {
   '{0:N2} {1}' -f $(
      if ($_ -lt 1kb) { $_, 'Bytes' }
      elseif ($_ -lt 1mb) { ($_/1kb), 'KB' }
      elseif ($_ -lt 1gb) { ($_/1mb), 'MB' }
      elseif ($_ -lt 1tb) { ($_/1gb), 'GB' }
      elseif ($_ -lt 1pb) { ($_/1tb), 'TB' }
      else { ($_/1pb), 'PB' }
   )
}

Get-WmiObject -Class win32_volume -ComputerName localhost | 
Where-Object{ $_.Capacity -gt 0} |
Foreach-Object{
   [PSCustomObject]@{
      SystemName  = $_.SystemName
      Driveletter = $_.DriveLetter
      label       = $_.Label
      Capacity    = $_.Capacity | Get-CapacitySize
      UsedSpace   = $($_.Capacity - $_.FreeSpace) | Get-CapacitySize
      FreeSpace   = $_.FreeSpace | Get-CapacitySize
      "Free(`%)"  = $("{0:P0}" -f $($_.FreeSpace /$_.Capacity)) 
   } 
} |
ForEach-Object{
   if($_."Free(`%)" -le '10%'){
      [console]::foregroundcolor = "magenta" 
      $_
   }
   else{
      [console]::foregroundcolor = "white" 
      $_
   }
}
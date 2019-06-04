

#convert to Bytes/KB/MB/GB/TB
function to_kmgt  {
  param
  (
    [System.Object]
    $bytes
  )
  
  foreach ($i in ('Bytes','KB','MB','GB','TB')) { if (($bytes -lt 1000) -or ($i -eq 'TB')) `
    { $bytes = ($bytes).tostring('F0' + '1') 
      return $bytes + " $i"
    }
    else {$bytes /= 1KB}
  }
}

# assign $sb to scriptblock: get-wmiobject win32_logicaldisk -filter "drivetype=3" 
# with the paramater -computername var $computername as an array
$sb={Param([array]$computername=$env:computername) `
get-wmiobject win32_logicaldisk -filter 'drivetype=3' -computername $computername}

$comp=@{n='Computer'; e={$g.pscomputername}}
$drv =@{n='Drive'; e={$g.deviceID}}
$size=@{n='Size'; e={to_kmgt($g.size)}}
$free=@{n='Free Space';e={to_kmgt($g.freespace)}}
$per =@{n='Percent';e={'{0:P0}' -f ([double]$g.freespace/[double]$g.size)}}

# use the call operator '&' to run commands that are stored 
# in variables and represented by strings
# & "[path] command" [arguments]
& $sb ny1,ly2,usnaspwfs01 | ForEach-Object {$g=$_; $g | 
Select-Object $comp, $drv, $size, $free, $per } | 
Format-Table -GroupBy computer 
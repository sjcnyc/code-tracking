

$ErrorActionPreference = 'silentlycontinue'
$ReportErrorShowSource = 'true'

[Reflection.Assembly]::LoadFile('C:\Users\sconnea\Dropbox\Development\POWERSHELL\assemblies\AlphaFS.dll') | Out-Null

# Calculate TB,GB,MB,KB,Bytes

function to_kmg  {
   param
   (
     [Object]
     $bytes
   )


foreach ($i in ('Bytes','KB','MB','GB','TB')) { if (($bytes -lt 1000) -or ($i -eq 'TB')){ $bytes = ($bytes).tostring('F0' + '1') 
  return $bytes + " $i"
  }
  else {$bytes /= 1KB}
  }
}
    $total = 0
    $path = '\\storage\offboard$'
    $sOption = [system.IO.SearchOption]::AllDirectories
    $mb=@{n='Size';e={to_kmg($total)}}

  try { #if ($sizeMB) {$size = $sizeMB*1MB} elseif ($sizeGB) {$size = $sizeGB*1GB}
  
       $output = [Alphaleonis.Win32.Filesystem.Directory]::GetFiles($path, '*', $soption) | % { $f = [Alphaleonis.Win32.Filesystem.DirectoryInfo]($_); $f } |
       Where-Object { $f.exists;} | Select-Object name, directoryname} 

  catch { $_.Exception.Message; continue}

$output | Format-Table -AutoSize
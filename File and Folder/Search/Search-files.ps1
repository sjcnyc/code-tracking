$ErrorActionPreference = 'silentlycontinue'
$ReportErrorShowSource = 'true'

[Reflection.Assembly]::LoadFile("$env:dev\_POWERSHELL\AlphaFS DLL\AlphaFS.dll") | Out-Null

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

function SearchFiles{
	param (
	[Parameter(Mandatory=$true, ValueFromPipeline = $true)][string]$Path,
	[Parameter(Mandatory=$false)][string]$SearchString,
	[Parameter(Mandatory=$true)][string]$lastWrite,
	[Parameter(Mandatory=$false)][int]$sizeMB,
	[Parameter(Mandatory=$false)][int]$sizeGB,
	[Parameter(Mandatory=$false)][string]$Export)

    $directory = [Alphaleonis.Win32.Filesystem.Directory]
    $sOption = [system.IO.SearchOption]::AllDirectories
    $mb=@{n='FileSize';e={to_kmg($f.length)}}

  
  try { if ($sizeMB) {$size = $sizeMB*1MB} elseif ($sizeGB) {$size = $sizeGB*1GB}
      

      
      $directory::GetFiles($Path, '*', $sOption) | % { $f = [Alphaleonis.Win32.Filesystem.FileInfo]($_); $f } | 
        Where-Object { $f.exists -and $f.name -like $searchString  -and $f.lastwritetime -le [System.datetime]::Parse($lastWrite) -and $f.length -ge $size -and !$_.PSiscontainer} | 
        Select-Object LastWriteTime, $mb, name, DirectoryName | Where-Object { if ($export) {export-csv $export -notype } else {Format-Table -auto}}
            
        
     }

  catch { $_.Exception.Message; continue}

  Finally { 
          
          [GC]::Collect();
          #$output.dispose();
     }
}


SearchFiles -path 'c:\windows\' -SearchString '*.*' -lastWrite '06/01/2011' #-Export "c:\temp\test.csv"
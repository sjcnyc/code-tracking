#REQUIRES -Version 2.0

$ErrorActionPreference = "silentlycontinue"
$ReportErrorShowSource = "true"

[Reflection.Assembly]::LoadFile("e:\DEVELOPMENT\POWERSHELL\NEW_POSH!\Release\AlphaFS.dll") | Out-Null
[System.Reflection.Assembly]::LoadFile("$PSScriptRoot\mptag\taglib-sharp.dll") | Out-Null

# Calculate TB,GB,MB,KB,Bytes
function to_kmg ($bytes) {

foreach ($i in ("Bytes","KB","MB","GB","TB")) { if (($bytes -lt 1000) -or ($i -eq "TB")){ $bytes = ($bytes).tostring("F0" + "1") 
  return $bytes + " $i"
  }
  else {$bytes /= 1KB}
  }
}

function Get-MediaInfo {
	param(
	[Parameter(ValueFromPipelineByPropertyName=$true)]
	[Alias('FullName')]
	$Path
	)

process {
	try {
		$obj = [taglib.File]::Create($Path)
	} catch {}

	if ($obj) {
		$obj = Add-SubProps $obj  'tag'
		Add-SubProps $obj  'properties'
	}

}
}

function SearchFiles{
	param (
	[Parameter(Mandatory=$true, ValueFromPipeline = $true)][string]$Path,
	[Parameter(Mandatory=$false)][string]$SearchString,
	[Parameter(Mandatory=$false)][int]$sizeMB,
	[Parameter(Mandatory=$false)][int]$sizeGB,
	[Parameter(Mandatory=$false)][string]$Export)

    $directory = [Alphaleonis.Win32.Filesystem.Directory]
    $sOption = [system.IO.SearchOption]::AllDirectories
    $fn=@{n="FileName";e={$f.name}}
    $mb=@{n="FileSize";e={to_kmg($f.length)}} 
    $vw=@{n="Width";e={$minfo.videowidth}}
    $vh=@{n="Height";e={$minfo.videoheight}}

 
    try { if ($sizeMB) {$size = $sizeMB*1MB} elseif ($sizeGB) {$size = $sizeGB*1GB}

    $result = $directory::GetFiles($Path, "*", $sOption) | 
     ForEach-Object { 
        $f = [Alphaleonis.Win32.Filesystem.FileInfo]($_); $f | 
         Where-Object { 
             $f.exists -and $f.name -like $searchString -and $f.length -gt $size -and !$_.PSiscontainer; 
             foreach ($minfo in Get-MediaInfo $f.fullname) {
             }
             }  
      }  | 
      Select-Object $fn, DirectoryName, $vw, $vh, $mb 
      
      if ($export) { $result | Export-Csv $export -NoTypeInformation }
      else { $result | Sort-Object filename | Format-Table -AutoSize }       
      Write-Host "Total: $($result.count)" 
     }

  catch { $_.Exception.Message; continue}

  Finally {    
           [GC]::Collect();
     }
}

SearchFiles -path 'D:\MEDIA\Video\HD_Movies' -SearchString "*.*" -sizeMB "2100" #-Export 'F:\TEST\movies_over_2500.csv'
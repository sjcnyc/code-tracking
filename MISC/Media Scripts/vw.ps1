[System.Reflection.Assembly]::LoadFile("$($PSScriptRoot)\mptag\taglib-sharp.dll") | out-null

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

function to_kmg ($bytes) {

foreach ($i in ("Bytes","KB","MB","GB","TB")) { if (($bytes -lt 1000) -or ($i -eq "TB")){ $bytes = ($bytes).tostring("F0" + "1") 
  return $bytes + " $i"
  }
  else {$bytes /= 1KB}
  }
}

function Get-videoInfo {
param (
	[Parameter(Mandatory=$true, ValueFromPipeline = $true)][string]$Path,
	[Parameter(Mandatory=$false, ValueFromPipeline = $true)][int]$width,
    [parameter(Mandatory=$true)][ValidateSet('ge','le','eq')][string]$opr )

$files =@("*.mkv","*.mp4","*.m4v","*.avi")

gci $path -Recurse -File -Include $files | foreach {

$f=$_;
$mb=@{n="FileSize";e={to_kmg($f.length)}}
$name=@{n="FileName";e={$f.Name}}
$fname=@{n="FullName";e={$f.DirectoryName}}

if ($opr -eq "ge"){
    Get-MediaInfo $f.FullName | ForEach-Object {$_} | 
    Where-Object {
         $_.videowidth -ge $width } | select $name, videowidth, videoheight, $mb }

if ($opr -eq "le") {    
    Get-MediaInfo $f.FullName | % {$_} | 
    ? { $_.videowidth -le $width } | select $name, videowidth, videoheight, $mb } 
   
if ($opr -eq "eq") {        Get-MediaInfo $f.FullName | % {$_} | 
    ? { $_.videowidth -eq $width } | select $name, videoWidth, videoheight, $mb  }  

} | Sort-Object filename | ft -AutoSize

}


Get-videoInfo -path D:\MEDIA\Video\HD_Movies -opr le -width 1199
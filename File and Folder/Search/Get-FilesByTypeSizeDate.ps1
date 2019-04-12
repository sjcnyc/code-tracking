#REQUIRES -Version 2

<#  
    .SYNOPSIS  
    Search for files by Extension, lastWriteTime, and Length fiter(s)

    .DESCRIPTION  
    Created to find large files on network share
    Recursive search for all files matching File type, size, and last write time
    [Alphaleonis.Win32.Filesystem] Assembly used for Unicode support of path/file > than 260 char. - http://alphafs.codeplex.com/

    .NOTES  
    File Name      : Get-FilesByTypeSizeDate.ps1  
    Author         : Sean Connealy
    Prerequisite   : PowerShell V2 over Vista and upper.
    
    .LINK  
    Script posted over: http://www.willMakeARepoSoon.com
      
    .PARAMETERS
    $path          : Path to share - "\\?\UNC\server\share\" 
    $searchString  : File Type to search for - "*.*" (? wildcard *.xls? will return *.xls & *.xlsx)
    $lastWrite     : The time when the current file was last written to - "01/01/1999" returns files <= 01/01/1999
    $sizeInMB      : Specify file size to search in MB - "50" returns files >= 50MB
    $sizeInGB      : Specify file size to search in GB - "1" returns files >= 1GB
    $export        : Export results to CSV file - "c:\foobar.csv"

    .SYNTAX
    Search-Files [-Path] <string> [[-SearchString] <string>] [-LastWrite] <string> [[-sizeMB] <int>] [[-sizeGB] <int>] [[-Export] <string>]  [<CommonParameters>]

    .EXAMPLE  
    Search-Files -Path "\\?\UNC\server\folders\" -SearchString "*.xls?" -LastWrite "01/01/2006" -SizeMB "60"

    ^Returns all files that match file type *.xls or *.xlsx, with a last write time less than or equal to 1/1/2006, 
    with a file size greater than or equal to 60MB
     
    SearchFile -Path "\\?\UNC\server\folders\" -SearchString "*.pst" -LastWrite "01/01/2009" -SizeGB "2" -Export "c:\foobar.csv"

    ^Returns all files that match file type *.pst, with a last write time less than or equal to 1/1/2009, with a file size greater 
    than or equal to 2MB, exporting results to CSV file   

#>



$null = [Reflection.Assembly]::LoadFile('C:\Users\sconnea\Dropbox\Development\POWERSHELL\Assemblies and DLLs\AlphaFS DLL\Debug\AlphaFS.dll')

# Calculate TB,GB,MB,KB,Bytes
function Get-BKMGT  {
  param
  (
    [Object]
    $bytes
  )
  foreach ($i in ('Bytes', 'KB', 'MB', 'GB', 'TB')) {
    if (($bytes -lt 1000) -or ($i -eq 'TB')){
      $bytes = ($bytes).tostring('F0' + '1') 
      return $bytes + " $i"
    }
    else {$bytes /= 1KB}
  }
}

function Search-Files{
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$Path,
    [Parameter(Mandatory = $false)][string]$SearchString,
    [Parameter(Mandatory = $false)][string]$lastWrite,
    [Parameter(Mandatory = $false)][int]$sizeMB,
    [Parameter(Mandatory = $false)][int]$sizeGB,
    [Parameter(Mandatory = $false)][string]$Export
  )

  $directory = [Alphaleonis.Win32.Filesystem.Directory]
  $sOption = [system.IO.SearchOption]::AllDirectories
  $f = [Alphaleonis.Win32.Filesystem.FileInfo]($_)  

  
  try {
    if ($sizeMB) {$size = $sizeMB*1MB} elseif ($sizeGB) {$size = $sizeGB*1GB}
      
    if ($Export) {
      $directory::GetFiles($Path, '*', $sOption) |
      ForEach-Object -Process {  
        $f
      } | 
      Where-Object -FilterScript { $f.exists -and $f.name -like $SearchString -and $f.lastwritetime -le [System.datetime]::Parse($lastWrite) -and $f.length -ge $size -and !$_.PSiscontainer} | 
      Select-Object -Property LastWriteTime, $mb, name, DirectoryName |
      Export-Csv $Export -NoTypeInformation
    } 
        
    else {
      $directory::GetFiles($Path, '*', $sOption) |
      ForEach-Object -Process {
        $f = [Alphaleonis.Win32.Filesystem.FileInfo]($_)
        $f
      } | 
      Where-Object -FilterScript { $f.exists -and $f.name -like $SearchString  -and $f.lastwritetime -le [System.datetime]::Parse($lastWrite) -and $f.length -ge $size -and !$_.PSiscontainer} | 
      Select-Object -Property LastWriteTime, $mb, name, DirectoryName |
      Sort-Object -Property FileSize  |
      Format-Table -AutoSize
    }
  }

  catch {
    $_.Exception.Message
  continue}

  Finally {
    [GC]::Collect()
    #$output.dispose();
  }
}


Search-Files -Path "\\storage\outlook$\jgreen" -SearchString '*.pst' -lastWrite '11/01/2016'      
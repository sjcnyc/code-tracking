#REQUIRES -Version 2.0

<#  
  .SYNOPSIS  
  Search for files by Extension, lastWriteTime, and Length

  .DESCRIPTION  
  Created to find large files on network share
  Recursive search for all files matching $searchString
  [Alphaleonis.Win32.Filesystem] Assembly used for Unicode paths greater than 260 char.  (http://alphafs.codeplex.com/)
  Filters on LastWriteTime and Length

  .NOTES  
  File Name      : Get-LargeOldFiles.ps1  
  Author         : Sean Connealy
  Prerequisite   : PowerShell V2 over Vista and upper.
    
  .LINK  
  Script posted over: http://www.willMakeARepoSoon.com
      
  .EXAMPLE  
  .\Get-LargeOldFiles -Path "\\server\folders\" -SearchString "*.xls?" -LastWrite "01/01/2006" -Size "60" 
  .\Get-LargeOldFiles -Path "\\server\folders\" -SearchString "*.xls?" -LastWrite "01/01/2006" -Size "60" -Export "c:\foobar"  

#>

$ErrorActionPreference = 'silentlycontinue'
$ReportErrorShowSource = 'true'

$null = [Reflection.Assembly]::LoadFile('C:\Users\sconnea\Dropbox\Development\POWERSHELL\Assemblies and DLLs\AlphaFS DLL\Release\AlphaFS.dll')

# Calculate TB,GB,MB,KB,Bytes

function to_kmg  
{
  param
  (
    [System.Object]
    $bytes
  )  
  
  foreach ($i in ('Bytes', 'KB', 'MB', 'GB', 'TB')) 
  {
    if (($bytes -lt 1000) -or ($i -eq 'TB'))
    {
      $bytes = ($bytes).tostring('F0' + '1') 
      return $bytes + " $i"
    }
    else 
    {
      $bytes /= 1KB
    }
  }
}

function Get-LargeOldFiles
{
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$Path,
    [Parameter(Mandatory = $false)][string]$SearchString,
    [Parameter(Mandatory = $true)][string]$lastWrite,
    [Parameter(Mandatory = $false)][int]$sizeMB,
    [Parameter(Mandatory = $false)][int]$sizeGB,
    [Parameter(Mandatory = $false)][string]$Export,
    [string]$username)
  
  $sOption = [system.IO.SearchOption]::AllDirectories
  $mb = @{
    n = 'FileSize'
    e = {
      to_kmg($f.length)
    }
  }
  
  TRY 
  { 
    if ($sizeMB) 
    {
      $size = $sizeMB*1MB
    }
    elseif ($sizeGB) 
    {
      $size = $sizeGB*1GB
    }
    
    $output = [Alphaleonis.Win32.Filesystem.Directory]::GetFiles($Path, '*', $sOption) | 
    ForEach-Object -Process {
      $f = [Alphaleonis.Win32.Filesystem.FileInfo]($_)
      $f
    } | 
    Where-Object -FilterScript {
      $f.exists -and $f.name -like $SearchString -and ! $_.PSiscontainer #-and $f.lastwritetime -le [System.datetime]::Parse($lastWrite) -and $f.length -ge $size -and !$_.PSiscontainer
    } | 
    Select-Object -Property LastWriteTime, $mb, name, DirectoryName, username
  }
  
  CATCH 
  { 
    $_.Exception.Message
    continue
  }
  
  FINALLY 
  { 
    if ($Export)
    {
      $output | Export-Csv $Export -NoTypeInformation  -Append
    } else 
    {
      $output |
      Sort-Object -Property filesize |
      Format-Table -AutoSize 
    }
    
    [GC]::Collect()
    $output.dispose()
  }
}

#



<#$path= @("\\storage\home$", "\\storage\outlook$")

@"
jdoelp
BARB05
syu0001
jparham
tbruh
mdillon
jjackson
mryang1
afinkels
jrappap
"@ -split [environment]::NewLine |

ForEach-Object { 

$username = $_

  foreach ($p in $path){   

       Get-LargeOldFiles -path "$($p)\$($_)" -SearchString '*.pst' -lastWrite '1/1/2016' -Export 'c:\temp\pstttt.csv'

  }
} #>
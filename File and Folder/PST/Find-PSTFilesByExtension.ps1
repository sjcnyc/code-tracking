  #Requires -Version 3.0 
  <# 
    .SYNOPSIS 
    Workflow to find PST files on share drive by extension
  
    .DESCRIPTION 
  
  
    .NOTES 
    File Name  : Find-PSTFilesByExtension
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 3/26/2015
  
    .LINK 
    This script posted to: http://www.github/sjcnyc
  
    .EXAMPLE
    Find-PSTFilesByExtension -username jgreen -keyword .pst
    .EXAMPLE
  
  #>
  
function Find-PSTFilesByExtension {
  param (
    [string]$username,
    [string]$keyword='.pst'
  )

  $path= @("\\storage\home$\$($username)\", "\\storage\outlook$\$($username)\")

  foreach ($p in $path) {
    Get-ChildItem $p -Recurse -File -Filter "*$($keyword)" -ea 0  | 
      Select-Object directory, name, @{N='size'; E={Get-ReadableStorage($_.length)}}
  } 
}

function Get-ReadableStorage {
   param
   (
     [System.Object]
     $size
   )
    $postfixes = @( 'B', 'KB', 'MB', 'GB', 'TB', 'PB' )
    for ($i=0; $size -ge 1024 -and $i -lt $postfixes.Length - 1; $i++) { $size = $size / 1024; }
    return '' + [System.Math]::Round($size,2) + ' ' + $postfixes[$i];
}

@"
jgreen
sconnea
"@ -split [environment]::NewLine |

ForEach-Object { Find-PSTFilesByExtension -username $_ } | Format-Table -AutoSize #| Export-Csv 'C:\TEMP\userPST.csv' -NoTypeInformation -Append}
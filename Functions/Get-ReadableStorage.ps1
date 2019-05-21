#Requires -Version 3.0 
<# 
    .SYNOPSIS

    .DESCRIPTION
 
    .NOTES 
        File Name  : Get-ReadableStorage
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/8/2015

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

#>

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

$storage = @"
5624750030848
65751510204416
71376260235264
5620894531584
65755365638144
71376260169728
5792852959232
65583407276032
71376260235264
"@-split [environment]::NewLine

foreach ($stor in $storage) {
 $stor + "`t=`t" + (Get-ReadableStorage -size $stor)
}
<# 
.SYNOPSIS 
    Defines a function to remove 'invalid' characters 
    from a file name. 
.DESCRIPTION 
    Some programs do not like certain 'invalid' characters 
    in a file name used by that application. The function 
    takes a look at each the file name and replaces some invalid 
    characters with '-'. 
 
    This function takes a file name and 'fixes' it and returns 
    the 'fixed' file name. Needless to say the characters to match 
    and what to replace them with is an application specific decision! 
.NOTES 
    File Name  : Fix-FileName.ps1 
    Author     : Thomas Lee - tfl@psp.co.uk 
    Requires   : PowerShell Version 3.0 
.LINK 
    This script posted to: 
        http://www.pshscripts.blogspot.com 
.EXAMPLE 
    Psh> .\Fix-FileName.ps1 
    File name was: 123{}{{{|[\] 
    Fixed name is: 123-------- 
 
#> 
 
 
Function Fix-FileName { 
[CMdletbinding()] 
Param ( 
$filename = $(throw 'no file name specified - returning') 
) 
 
Switch -Regex ($fn) { 
  '}'  { $fn = $fn -replace '{','-'  } 
  '}'  { $fn = $fn -replace '}','-'  } 
  '\]' { $fn = $fn -replace ']','-'  } 
  '\[' { $fn = $fn -replace '\[','-' } 
  '\\' { $fn = $fn -replace '\\','-' } 
  '\|' { $fn = $fn -replace '\|','-' } 
} 
$fn 
} 
 
$fn = '123{}{{{|[\]' 
#$fnf = Fix-FileName $fn 
#"File name was: $fn" 
#"Fixed name is: $fnf" 
#Requires -Version 3.0 
<# 
.SYNOPSIS 
    This is a PowerShell function to remove invalid characters from strings to be used as file names. 

.DESCRIPTION 
    The function takes a string parameter called Name and returns a string that has been stripped of invalid
    file name characters, i.e. *, :, \, /.  The Name parameter will also receive input from the pipeline. 

.PARAMETER Name 
    Specifies the file name to strip of invalid characters. 
 
.INPUTS 
    Parameter Name accepts System.String objects from the pipeline. 
 
.OUTPUTS 
    System.String.  Outpus a string object 
 
.NOTES 
    File Name  : Remove-InvalidFileNameChars
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 3/26/2014
.LINK 
    This script posted to: 
        http://www.github/sjcnyc
.EXAMPLE
    Remove-InvalidFileNameChars -Name "<This/name\is*an:illegal?filename>" 
    PS C:\>Thisnameisanillegalfilename 

.EXAMPLE

#>

Function Remove-InvalidFileNameChars { 
 
    [CmdletBinding()]  
    param([Parameter(Mandatory=$true, 
        Position=0, 
        ValueFromPipeline=$true,  
        ValueFromPipelineByPropertyName=$true)] 
        [String]$Name 
    ) 
 
    return [RegEx]::Replace($Name, '[{0}]' -f ([RegEx]::Escape([String][System.IO.Path]::GetInvalidFileNameChars())), ' ') 
}
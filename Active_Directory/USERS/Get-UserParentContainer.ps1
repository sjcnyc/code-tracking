#Requires -Version 3.0 
<# 
.SYNOPSIS 

.DESCRIPTION 

 
.NOTES 
    File Name  : Get-UserParentContainer
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
.LINK 
    This script posted to: 
        http://www.github/sjcnyc
.EXAMPLE

.EXAMPLE

#>
@"
sean.connealy.peak@sonymusic.com
"@ -split [environment]::NewLine |

Get-QADUser | 
    Select-Object parentcontainer, name, samaccountname | 
    Sort-Object parentcontainer
#Requires -Version 3.0 
<# 
.SYNOPSIS 

.DESCRIPTION 

 
.NOTES 
    File Name  : Convert-Name2SamName-
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
.LINK 
    This script posted to: 
        http://www.github/sjcnyc
.EXAMPLE

.EXAMPLE

#>
@"
Sam Bruce 
Paula Erickson
Ron Mirro 
Andrew Ross 
Sue Zotian 
Frank Lipari 
Caroline Symannek
"@ -split [environment]::NewLine |

Get-QADUser | 
ForEach-Object {
	"$($_.samaccountname)" 
} 

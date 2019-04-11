#Requires -Version 3.0 
<# 
.SYNOPSIS 

.DESCRIPTION 

 
.NOTES 
    File Name  : Get-UserDistributionLists
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
.LINK 
    This script posted to: 
        http://www.github/sjcnyc
.EXAMPLE

.EXAMPLE

#>

@"
Glbl Mkt – All Catalogue
"@ -split [environment]::NewLine |

Get-QADUser -Service 'mnet.biz' | ForEach-Object {
  $_.memberof |
  Get-QADGroup | Where-Object { $_.name -like 'GDL*' } |
  Select-Object displayname,alias,mail |
  Add-Member -MemberType NoteProperty -Name 'UserName' -Value $_.displayname -PassThru 
}

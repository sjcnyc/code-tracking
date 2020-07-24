#Requires -Version 3.0 
<# 
.SYNOPSIS 

.DESCRIPTION 

.NOTES 
    File Name  : Get-UserManager
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0
    Date       : 3/28/2014
.LINK 
    This script posted to: 
        http://www.github/sjcnyc
.EXAMPLE

.EXAMPLE

#>

function Get-UserManager {
  param
  (
    [System.Object]
    $user
  )

	get-qaduser $user | 
	Select-Object name, @{Name='Manager';Expression={(get-qaduser $_.Manager).name}}
}
#Requires -Version 3.0
<#
  .SYNOPSIS


  .DESCRIPTION


  .NOTES
  File Name  : Get-SecurityGroups.ps1
  Author     : Sean Connealy
  Requires   : PowerShell Version 3.0
  Date       : 9/26/2014

  .LINK
  This script posted to: http://www.github/sjcnyc

  .EXAMPLE

  .EXAMPLE

  #>

Function Get-SecurityGroups {
    [cmdletbinding()]
    param (
        [parameter(mandatory = $true, position = 0)]$group
    )
    begin {}
    process {
        Get-QADGroup `
               -SizeLimit 0 `
               -SearchRoot 'OU=GRP,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com' `
               -Name "*$($group)*" | Select-Object samaccountname
    }
    end {}
}

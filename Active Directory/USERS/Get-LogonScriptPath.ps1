#Requires -Version 3.0 
<# 
.SYNOPSIS 

.DESCRIPTION 

 
.NOTES 
    File Name  : Get-LogonScriptPath
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0
    Date       : 3/28/2014
.LINK 
    This script posted to: 
        http://www.github/sjcnyc
.EXAMPLE
    get-scriptPath -ous bvh,usa -export -path c:\temp\test -filename test.csv

.EXAMPLE
    get-scriptPath -ous bvh,usa

#>

function Get-LogonScriptPath {
  param (
    [Parameter(Mandatory=$true, 
    ValueFromPipeline = $true)]
    [array]$ous, 
    [switch]$export, 
    [string]$path,
    [string]$filename='scriptpaths.csv'
  )
  
  begin{} 
  process {
    try {			
      $obj =@()			
      $ous | 
      ForEach-Object {
        $obj +=	Get-QADUser -SearchRoot bmg.bagint.com/$_ `
        -DontUseDefaultIncludedProperties `
        -sizelimit 0 `
        -IncludedProperties samaccountname, dn, scriptpath |
        
        Select-Object parentcontainer, samaccountname, scriptpath | 
        Where-Object { 
          $_.scriptpath -ne $null 
        } 
      }
      if ($export) {$obj | Export-Csv "$($path)\$($filename)" -NoType}
      else { $obj }
    } catch { $_.exception.message;continue }
  }
  end{}
}
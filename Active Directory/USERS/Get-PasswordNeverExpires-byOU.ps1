#Requires -Version 3.0 
<# 
.SYNOPSIS 

.DESCRIPTION 

 
.NOTES 
    File Name  : Get-PasswordNeverExpires-byOU
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0
    Date       : 3/28/2014
.LINK 
    This script posted to: 
        http://www.github/sjcnyc
.EXAMPLE

.EXAMPLE

#>

function Get-PassNeverExpires {
  param (
  [Parameter(Mandatory=$true, ValueFromPipeline = $true)][array]$ous)
  
  begin{} 
  process {
    try {
      
      $ous | ForEach-Object { 
        Get-QADUser -SearchRoot "bmg.bagint.com/$_" -PasswordNeverExpires 
      }  | Select-Object Name, parentcontainer, PasswordNeverExpires
      
    } catch {$_.exception.message;continue}
  }
  end{}
}

get-passNeverExpires -ous usa 
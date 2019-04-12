#Requires -Version 3.0 
<# 
  .SYNOPSIS 
      Exclude files and folders in a Get-ChildItem recursive search
  
  .DESCRIPTION 
      Exclude files and folders in a Get-ChildItem recursive search  
      Useful for excluding files & folders while running a cleanup script.      
  
  .NOTES 
      File Name  : Get-GciExclude
      Author     : Sean Connealy
      Requires   : PowerShell Version 3.0 
      Date       : 5/1/2014
  
  .LINK 
      This script posted to: http://www.github/sjcnyc
  
  .EXAMPLE
      Get-GciExclude -path 'c:\' -exclude 'Temp','.csv', '.txt'
      Will exclude the Temp folder and contents, and all *.csv & *.txt
      during a recursive search. 
  .EXAMPLE
#>  

function Get-GciExclude  {
  param
  (
    [System.Object]
    $path,
    
    [System.Object]
    $exclude
  )
  
  $Selectprop = @{'Property'='Fullname','Length','PSIsContainer'} 
  
  $array = @(Get-Childitem $path -recurse -ea 0 -force | Select-Object @SelectProp)
  
  $folders = @($array | Where-Object {$_.PSIsContainer -eq $True}) 
  $files   = @($array | Where-Object {$_.PSIsContainer -eq $False}) 
  
  for ($j = 0; $j -lt $exclude.count; $j++) { 
    $files = $files | 
    Where-Object {
      $_.fullname -notmatch $exclude[$j]
    }
    $exclude[$j] = $exclude[$j].substring(0,$exclude[$j].length-2) 
    
    $folders = $folders | 
    Where-Object {
      $_.fullname -notmatch $exclude[$j] 
    } 
  }
  # Return files not matching exclude 
  Return $files.fullname
}

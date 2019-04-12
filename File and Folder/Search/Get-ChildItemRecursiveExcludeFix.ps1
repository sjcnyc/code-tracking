$folderpath = 'c:\'

#Example: 'Windows', 'temp', '*.txt', 'someDoc.doc'

$exclude = @('excludeFolders', 'excludeFiles')

$Selectprop = @{'Property'='Fullname','Length','PSIsContainer'} 

$array = @(Get-Childitem $folderpath -recurse -ea 0 -force | Select-Object @SelectProp)

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

$folders
$files

$Moviepath = "d:\media\video\movies\"
cls

$result = Get-ChildItem -path $Moviepath -Recurse -include "*.srt" | 
    % { $_ } | ? { $_.name -like "*cd1.*" -or $_.name -like "*cd2.*" -and !$_.psiscontainer} 
$result | select directory, name | ft -auto

<#
write-host "Processing Files - [BEGIN]" 
Foreach ($file in $result){
  
  $filename = $file.name 
  $arg1 = $file.fullname | ? { $file.fullname -like "*cd1.*"}  

  foreach ($arg in $arg1) {
      
      $arg2 = $arg1 -replace "cd1", "cd2"
      $arg3 = $arg1 -replace "cd1", ""
      $allArgs = @("`"$arg3`"","`"$arg1`"","`"$arg2`"")
      $mencode = "C:\mencode\mencoder.exe -oac copy -ovc copy -noodml -o"
      $fin = $arg3 -replace ".avi", " "
       
      write-host "-Joining: " $arg1.split("\")[-1] " AND " $arg2.Split("\")[-1] -NoNew -Fore Cyan
      start-process "cmd" -ArgumentList "/c", "$mencode $allArgs" -wait 
      write-host " - [DONE]" -ForegroundColor Yellow
          
      write-host "Deleting: " $arg1.split("\")[-1] -NoNew -Fore Red
      remove-Item $arg1
      write-host " - [DONE]" -Fore Yellow

      write-host "Deleting: " $arg2.split("\")[-1] -NoNew -Fore Red
      remove-Item $arg2
      write-host " - [DONE]" -Fore Yellow
   }
}
write-host "Processing Files - [FINISH]" 

 #>



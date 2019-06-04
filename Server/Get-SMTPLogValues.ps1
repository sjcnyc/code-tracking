﻿#requires -Version 1
param([String] $LogDirectory = $(throw 'Please specify path for a Log for Directory'),
[int32] $timerange = $(throw 'Please specify a Time Range in Hours'))
$reqhash1 = @{ }
$Di = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList $LogDirectory
foreach($fs in $Di.GetFileSystemInfos()){
  if ($fs.LastWriteTime -gt [DateTime]::get_Now().AddHours(-$timerange) ){
    foreach ($line in $(Get-Content -Path $fs.Fullname)){
      if ($line.Substring(0,1) -ne '#'){
        $larry = $line.split(' ')
        if ($larry[3] -ne 'OutboundConnectionCommand'){
          if ($larry[8] -eq 'MAIL'){
            $ltime = [System.Convert]::ToDateTime($larry[0] + ' ' + $larry[1])
            if($ltime -gt [DateTime]::get_UtcNow().addhours(-$timerange)){
              $femail = $larry[10].Substring($larry[10].IndexOf('<')+1,$larry[10].IndexOf('>')-$larry[10].IndexOf('<')-1)
              $fdomain = $femail.Remove(0, $femail.IndexOf('@')+1) 
              if($reqhash1.ContainsKey($fdomain)){
                $hashtabedit = $reqhash1[$fdomain]
                if($hashtabedit.ContainsKey($larry[2] + '/' + $fdomain)){$hashtabedit[$larry[2] + '/' + $fdomain] = $hashtabedit[$larry[2] + '/' + $fdomain] + 1}
                else{$hashtabedit.Add($larry[2] + '/' + $fdomain,1)} 
              }
              else{
                $reqhash2 = @{ }
                $reqhash2.Add($larry[2] + '/' + $fdomain,1)
                $reqhash1.Add($fdomain,$reqhash2)
              }
            }
          }
        }
      }
    } 
  } 
}
foreach ($htent in $reqhash1.keys){
  $htent
  $reqhash2 = $reqhash1[$htent]
  foreach ($htent1 in $reqhash2.keys){' ' + $htent1.Substring(0,$htent1.IndexOf('/')) + ' ' + $reqhash2[$htent1]}
} 
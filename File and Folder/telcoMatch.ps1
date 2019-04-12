#requires -Version 3
$data = Import-Csv -Path C:\temp\_telco_dump\8434d.csv

foreach ($d in $data){
  $call1 = $d -split ';' |
  Where-Object -FilterScript { $_ -match 'CallApp(.*)' } |
  ForEach-Object -Process { ($Matches[0]).Substring(8)} |
  Select-Object -Unique

  $brdg1 = $d -split ';' |
  Where-Object -FilterScript { $_ -match 'BrdgApp(.*)|BrdApp(.*)' }  |
  ForEach-Object -Process { ($Matches[0]).Substring(8)} |
  Select-Object -Unique

  $autoIcom = $d -split ';' |
  Where-Object -FilterScript { $_ -match 'AutoIcom(.*)'} |
  ForEach-Object -Process { ($Matches[0]).Substring(10)} |
  Select-Object -Unique

  $phoneObj = [pscustomobject] @{
    'Name'              = $d.name
    'Extension'         = $d.Extension
    'Call Appearance'   = ($call1 | Out-String).Trim()
    'Bridge Appearance' = ($brdg1 | Out-String).Trim()
    'Auto Icom'         = ($autoIcom | Out-String).Trim()
  }

  $phoneObj  | Export-Csv -Path C:\temp\_telcofinal\test8434d.csv -NoTypeInformation -Append
}
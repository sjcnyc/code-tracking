$devices = Invoke-SSHCommand -Command 'isi_for_array isi devices' -SessionId 1 | Select-Object -ExpandProperty Output

#$devices.replace(' [42;30m[HEALTHY][0m','[HEALTHY]').replace('[42;30m[ OK ][0m','[ OK ]') | Format-Table -AutoSize | Out-Notepad


$nodes = Invoke-SSHCommand -Command 'isi_for_array -s "isi devices | grep -v HEALTHY"' -SessionId 1 | Select-Object -ExpandProperty Output 

#$nodes.replace('[42;30m[ OK ][0m','[ OK ]') | Format-Table -AutoSize | Out-Notepad


$outputObj = [pscustomobject] @{

devices = ($devices.replace(' [42;30m[HEALTHY][0m','[HEALTHY]').replace('[42;30m[ OK ][0m','[ OK ]') | Out-String).Trim()
nodes =  ($nodes.replace('[42;30m[ OK ][0m','[ OK ]') | Out-String).Trim()

}



$outputObj
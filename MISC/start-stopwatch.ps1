$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
 
write-host "Script Started at $(get-date)"

$user=get-qaduser -SearchRoot 'bmg.bagint.com/usa' -SizeLimit 100 

write-host $user.count
Write-Host ''
write-host "Script Ended at $(get-date)"
write-host "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
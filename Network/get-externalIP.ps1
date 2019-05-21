$url = 'http://checkip.dyndns.com' 
$webclient = New-Object System.Net.WebClient
$Ip = $webclient.DownloadString($url)
$Ip = $Ip.ToString()
$ip = $Ip.Split(' ')
$ip = $ip[5]
$ip = $ip.replace('</body>','')
$FinalIPAddress = $ip.replace('</html>','')

Write-Host "External IP: $($FinalIPAddress)" -f Cyan
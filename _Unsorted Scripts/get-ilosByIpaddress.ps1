Import-Module HPiLOCmdlets
 
$IPs = Get-Content C:\CSV\ip.txt
 
foreach ($IP in $IPs)
 
{
[system.net.ipaddress]$IP =$IP
 
$iLO = Find-HPiLO $IP.IPAddressToString -Timeout 100
 
$ILO | Export-Csv C:\CSV\iLO_Information.CSV -Append -NoTypeInformation
}
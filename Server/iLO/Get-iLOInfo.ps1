Import-Module -Name HPiLOCmdlets

@"
10.12.1.23
"@ -split [environment]::NewLine | ForEach-Object {
 
 try
 { 

  [system.net.ipaddress]$IP = $_
 
  $iLO = Find-HPiLO $IP.IPAddressToString -Timeout 100 -Verbose 
 
  $ILO #| Export-Csv -Path "$env:HOMEDRIVE\Temp\iLO_info.csv" -Append -NoTypeInformation
 
 }
 catch
 {
   "Error was $_"
 }

}
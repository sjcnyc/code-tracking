Add-Type -AssemblyName Microsoft.PowerShell.Commands.Utility
function Test-SNMP 
{
  param (
  
    [string]$ipaddress,
    [string]$server
  )  
  
  try
  {
    $SNMPtest = Invoke-SnmpWalk -IpAddress $ipaddress -Version Ver2 -TimeOut 1 -ErrorAction 0
  }
  catch 
  {
    [Management.Automation.ErrorRecord]$e = $_
    
    Write-Verbose -Message $e.Exception.Message
  }
  
  if ($SNMPtest -notmatch 'OID')
  {
    Write-Host -Object "`r`nSNMP enabled :  $($ipaddress) on Server $($server) " -ForegroundColor Red -NoNewline
  }
  else 
  {
    Write-Host -Object "`r`nSNMP disabled : $($ipaddress) on Server $($server) " -ForegroundColor Green -NoNewline
  }
}

$computers = @"
25mad
ny1
ly2
usnaspwfs01
usbvhpwfs01
"@-split [environment]::NewLine

try
{
  foreach ($comp in $computers)
  {
    $ipaddress = Get-Printers -ComputerName $comp | Select-Object -ExpandProperty ipaddress

    foreach ($ip in $ipaddress) 
    {
      Test-SNMP -ipaddress $ip -server $comp
    }
  }
}

catch [Microsoft.PowerShell.Commands.WriteErrorException]
{
  [Management.Automation.ErrorRecord]$e = $_
  
  Write-Verbose -Message $e.Exception.Message
}

function Disable-SNMP 
{
  param (
    [Parameter(Mandatory)][string]$servername  
  )
  
  #Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\Standard TCP/IP Port\Ports"
  
  Invoke-Command -ComputerName $servername -ScriptBlock {
    Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\Standard TCP/IP Port\Ports'
  } | ForEach-Object -Process {
    Set-ItemProperty -Path $_.PSPath -Name 'SNMP Enabled' -Value 0
  }
}




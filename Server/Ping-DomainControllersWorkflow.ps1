#requires -Version 3
workflow Test-WFConnection  
{
  param
  (
    [System.Object]
    $Computers
  )
  
  foreach -parallel ($computer in $Computers)
  {
    Test-Ping -computername $computer
  }
}

function Test-Ping  
{
  param
  (
    [System.Object]
    $computername
  )
  
  $result = [pscustomobject]@{
    DomainController = $computername
    Status           = 'Unavailable'
    IPAddress        = [System.Net.Dns]::GetHostAddresses($computername).IPAddressToString
  }            
  if (Test-Connection -ComputerName $computername -Count 1 -Quiet)
  {
    $result.Status = 'Available'
  }
  $result #| Export-Csv -Path "$env:HOMEDRIVE\Temp\domaincontrollers.csv" -NoTypeInformation -Append
}

Get-QADComputer -ComputerRole 'DomainController' | Select-Object -Property name | 
  ForEach-Object -Process {
    Test-WFConnection -Computers $_.name |  Select-Object -Property status, domaincontroller, ipaddress
}

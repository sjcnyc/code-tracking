using namespace System.Collections.Generic




$Computers = [List[PSObject]]::new()

foreach ($Server in ((Import-Csv 'C:\Temp\Pulse computer names.csv').Computername)) {
  try {
    Get-ADComputer $Server -ErrorAction Stop -Server me.sonymusic.com | Out-Null
    $Result = $true
  }
  catch {
    $Result = $False
  }
  $PSObjs = [PSCustomObject]@{
    ComputerName = $Server
    Found        = $Result
  }
  [void]$Computers.Add($PSObjs)
}

$Computers | Export-Csv c:\temp\Computers_ME.csv -NoTypeInformation
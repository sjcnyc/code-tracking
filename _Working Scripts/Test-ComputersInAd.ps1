using namespace System.Collections.Generic

$Computers = [List[PSObject]]::new()

foreach ($server in ((Import-Csv 'C:\Temp\Pulse computer names.csv').Computername)) {
  Try {
    Get-ADComputer $server -ErrorAction Stop -Server me.sonymusic.com | Out-Null
    $Result = $true
  }
  Catch {
    $Result = $False
  }
  $PSObjs = [PSCustomObject]@{
    Name  = $server
    Found = $Result
  }
  [void]$Computers.Add($PSObjs)
}

$Computers | Export-Csv c:\temp\Computers_ME.csv -NoTypeInformation
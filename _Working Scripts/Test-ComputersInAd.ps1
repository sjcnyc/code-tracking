using namespace System.Collections.Generic

function Test-ComputerIsInAd {
  [CmdletBinding()]
  param (
    [array]
    $Computers,

    [string]
    $Domain
  )

  $CompList = [List[PSObject]]::new()

  foreach ($Server in $Computers) {
    try {
      Get-ADComputer $Server -ErrorAction Stop -Server $Domain | Out-Null
      $Result = $true
    }
    catch {
      $Result = $false
    }
    $PSObjs = [PSCustomObject]@{
      ComputerName = $Server
      Found        = $Result
    }
    [void]$CompList.Add($PSObjs)
  }
  return $CompList
}

$Servers = (Import-Csv 'C:\Temp\Pulse computer names.csv').Computername

Test-ComputerIsInAd -Computers $Servers -Domain 'me.sonymusic.com' | Export-Csv c:\temp\Computers_ME.csv -NoTypeInformation
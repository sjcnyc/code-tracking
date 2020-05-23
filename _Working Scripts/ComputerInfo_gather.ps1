using namespace System.Collections.Generic

$List = [List[PSObject]]::new()

$mappings = Get-SmbMapping

foreach ($mapping in $mappings) {
  $psObject = [pscustomobject]@{
    Mapping =
    [pscustomobject]@{
      Drive = $mapping.LocalPath
      Path  = $mapping.RemotePath
    }
  }
  [void]$List.Add($psObject)
}

$computerInfo = Get-ComputerInfo

foreach ($comp in $computerInfo) {
  $psObject = [pscustomobject]@{
    Hostname    = $comp.CsDNSHostName
    Domain      = $comp.CsDomain
    LogonServer = $comp.LogonServer
    ProductName = $comp.WindowsProductName
    OSVersion   = $comp.OsVersion

  }
  [void]$List.Add($psObject)
}


$List | ConvertTo-Json
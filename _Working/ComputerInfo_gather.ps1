using namespace System.Collections.Generic

$List = [List[PSObject]]::new()
$jsonBase = @{ }

$mappings = (Get-SmbMapping).Where{ $_.status -eq "OK" -and (![String]::IsNullOrWhiteSpace($_.LocalPath)) }
$computerInfo = Get-ComputerInfo

foreach ($comp in $computerInfo) {
  $psObject = [pscustomobject]@{
    HostInfo =
    [pscustomobject]@{
      Hostname    = $comp.CsDNSHostName
      Domain      = $comp.CsDomain
      LogonServer = $comp.LogonServer
      ProductName = $comp.WindowsProductName
      OSVersion   = $comp.OsVersion
    }
  }
  [void]$List.Add($psObject)
}

foreach ($mapping in $mappings) {
  $psObject = [pscustomobject]@{
    Mappings =
    [pscustomobject]@{
      Drive = $mapping.LocalPath
      Path  = $mapping.RemotePath
    }
  }
  [void]$List.Add($psObject)
}

$users = @{"Users" = $List;}
$jsonBase.Add("Data", $users)
$jsonBase | ConvertTo-Json -Depth 10


<# $Arr = foreach ($Object in $mappings) {
  $copy = [PSCustomObject]::new()
  $Object.PSObject.Properties | ForEach-Object {
    $copy | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
  }
  $copy
}

$Arr #>
using namespace System.Collections.Generic

$Global:ConfigJson = Get-Content -Path D:\PwSh\Powershell-Scripts\Scratch\Config.json -Encoding Default | ConvertFrom-Json

$Global:Groups = @()

# Load config.json in to PS Generic List
$PSList = [List[psobject]]::new()

foreach ($item in $ConfigJson) {
  $psobject = [pscustomobject]@{
    'UPNs'         = $item.CustomUPNSuffixes
    'Domain'       = $item.DomainDN
    'SubDomain'    = $item.SubDomainDN
    'DNSRoot'      = $item.DNSRoot
    'IsilonPath'   = $item.IsilonPath
    'CustomGroups' = $item.CustomGroups
    'AboutInfo'    = $item.About
  }
  $PSList.Add($psobject)
}
# Make Global
$Global:CustomConfig = $PSList

$Groups = @()

foreach ($Group in $CustomConfig.CustomGroups) {
  if (-not [string]::IsNullOrWhiteSpace($Group.Name)) {
    $Groups += $Group.Name
  }
}


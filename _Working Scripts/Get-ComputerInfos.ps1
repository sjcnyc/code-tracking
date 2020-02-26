function Get-ComputerInfos() {

  $DiskOutput = Get-SMBMapping | Sort-Object | Select-Object LocalPath, RemotePath

  return @"
Computer name:          $($env:COMPUTERNAME)
Domain:                 $($env:USERDOMAIN)
Username:               $($env:USERNAME)
Version:                $([Environment]::OSVersion.VersionString)
PSVersion:              $($PSVersionTable.PSVersion)
$($DiskOutput | Out-String)
IPAddress:              $(Resolve-DnsName -Type A -Name $env:computername | select -ExpandProperty IPAddress)
"@
}

Get-ComputerInfos
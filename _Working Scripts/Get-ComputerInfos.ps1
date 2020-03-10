function Get-ComputerInfos {
  param (
    [string]$ComputerName
  )

  $DiskOutput = Get-SMBMapping | Sort-Object | Select-Object LocalPath, RemotePath

  return @"
ComputerName:           $($env:COMPUTERNAME)
Domain:                 $($env:USERDOMAIN)
IPAddress:              $(Resolve-DnsName -Type A -Name $env:computername | Select-Object -ExpandProperty IPAddress)
UserName:               $($env:USERNAME)
Version:                $([Environment]::OSVersion.VersionString)
PSVersion:              $($PSVersionTable.PSVersion)
$($DiskOutput | Out-String)

"@
}

Get-ComputerInfos -ComputerName $env:COMPUTERNAME


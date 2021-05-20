$object = [pscustomobject]@{

  Name         = $($ENV:USERNAME)
  HostName     = $($ENV:COMPUTERNAME)
  Domain       = $($ENV:USERDOMAIN)
  IPAddress    = $(Resolve-DnsName -Type A -Name $env:computername | Select-Object -ExpandProperty IPAddress)

  MappedDrives = & {
    foreach ($service in (Get-SMBMapping)) {
      Write-Output ([pscustomobject][ordered]@{
          Drive = $service.LocalPath
          Path  = $service.RemotePath
        }
      )
    }
  }
}

$UserObject = [pscustomobject]@{
  Name         = $object.Name
  HostName     = $object.HostName
  Domain       = $object.Domain
  IPAddress    = $object.IPAddress
  MappedDrives = (($object).MappedDrives | Out-String).Trim()
}

$UserObject
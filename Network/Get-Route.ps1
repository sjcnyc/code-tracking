function Get-Route {
  ROUTE.EXE print -4 | 
    foreach-object { 
        $i = $_ | Select-Object -Property Destination , Netmask , Gateway , Interface, Metric
        $null, $i.destination, $i.netmask, $i.gateway, $i.interface, $i.metric=
                ($_ -split '\s{2,}')
  if ([bool]($i.Destination -as [ipaddress])) { $i }} | Select-Object -Property * 
}
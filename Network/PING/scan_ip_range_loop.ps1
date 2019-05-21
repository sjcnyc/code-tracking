function ping-ip {
  param( $ip )
  trap {$false; continue}
  $timeout = 1000
  $object = New-Object system.Net.NetworkInformation.Ping
  (($object.Send($ip, $timeout)).Status -eq 'Success')
}

0..255 | % { $ip = "162.49.2.$_"; "$ip = $(ping-ip $ip)" }
$users = Get-ADUser -Properties proxyaddresses -server 'me.sonymusic.com' -Filter *
$maxProxy = $users | ForEach-Object {$_.proxyaddresses.count} | Sort-Object | Select-Object -Last 1

Foreach ($u in $users) {
  $proxyAddress = [ordered]@{}
  $proxyAddress.add("User", $u.name)

  For ($i = 0; $i -lt $maxProxy; $i++) {
    $proxyAddress.add("ProxyAddress_$i", $u.proxyaddresses[$i])
  }

  [pscustomobject]$proxyAddress | Export-Csv -Path C:\Temp\me_proxy2.csv -NoTypeInformation –Append -Force
  Remove-Variable -Name proxyAddress
}
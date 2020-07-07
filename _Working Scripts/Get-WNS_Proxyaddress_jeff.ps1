(Get-AdUser -Filter * -Properties 'ProxyAddresses').Where{
  $_.ProxyAddresses -like "*.wns@sonymusic.com" -or
  $_.ProxyAddresses -like "*.eswns@sonymusic.com"
} | Select-Object UserPrincipalName
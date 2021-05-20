
Get-ADUser sconnea -properties * | select-object name, samaccountname, surname, enabled, @{"name" = "proxyaddresses"; "expression" = {$_.proxyaddresses}} | Export-Csv ProxyAddress.csv
Get-ADUser -Filter * -SearchBase 'dc=MNET,dc=BIZ' -Properties proxyaddresses | Select-Object name, @{L = 'ProxyAddress_1'; E = {$_.proxyaddresses[0]}}, @{L = 'ProxyAddress_2'; E = {$_.ProxyAddresses[1]}} | Export-Csv ProxyAddress.csv –NoTypeInformation
Get-ADObject -Properties mail, proxyAddresses -Filter {proxyAddresses -eq "smtp:sconnea@sonymusic.com"}
Get-ADObject -Properties mail, proxyAddresses -Filter {mail -like "*sconnea@sonymusic.com*" -or proxyAddresses -like "*sconnea@sonymusic.com*"}
Get-ADObject -LDAPFilter "(|(mail=sconnea@sonymusic.com)(proxyAddresses=smtp:sconnea@sonymusic.com))"
Get-ADObject -LDAPFilter "(|(mail=*sconnea@sonymusic.com*)(proxyAddresses=*sconnea@sonymusic.com*))"
Get-ADObject -Properties proxyAddresses -Filter {proxyAddresses -eq "sip:sconnea@sonymusic.com"}
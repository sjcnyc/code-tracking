<#(((Get-QADUser -Service 'nycmnetads001.mnet.biz:389' atorre1 -IncludeAllProperties).ProxyAddresses) | out-string).Trim()


(Get-QADUser -Service 'nycmnetads001.mnet.biz:389' atorre1 -IncludeAllProperties).PrimarySMTPAddress

(Get-QADUser atorre1).mail

#>


#samaccountname, proxy
#sconnea, sconnea@sony.com;sconnea@sonymusic.com


Import-Csv proxy.csv | ForEach-Object {
	Get-ADUser $_.Name | Set-ADUser -Add @{proxyAddresses = ($_.proxy -split ";")}
}

(Get-ADUser sconnea -Properties proxyaddresses).proxyaddresses



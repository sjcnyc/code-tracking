function Get-NameFromDN {
  param
  (
    [System.String]
    $DN
  )

  return ($DN.replace('\', '') -split ',*..=')[2]
}

Get-ADUser -Filter * | Select-Object Name, SamAccountName,
@{Name = "OU"; Expression = { Get-NameFromDN $_.distinguishedname } }, distinguishedname -First 100 |
Where-Object OU |
Group-Object -Property OU -NoElement |
Sort-Object Count -Descending




#$Dn = "OU=Laptops - Tablets,OU=Workstations,OU=Computers,OU=CHC Servers and Computers,dc=domain,dc=local"

#$DN -replace '^cn=|,(OU|CN)=.+|\\'
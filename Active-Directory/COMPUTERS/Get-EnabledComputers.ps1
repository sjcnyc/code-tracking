(Get-QADComputer -SearchRoot 'DC=bmg,DC=bagint,DC=com' -SizeLimit 0 -LdapFilter '(!(userAccountControl:1.2.840.113556.1.4.803:=2))' |  
  Where-Object { $_.osname -notlike '*Server*'} |
Select-Object samaccountname, name, osname).count 
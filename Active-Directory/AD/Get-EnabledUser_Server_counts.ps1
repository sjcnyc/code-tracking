(Get-QADUser -Enabled -SizeLimit 0).count


(Get-QADComputer -SizeLimit 0 -LdapFilter "(&(objectCategory=computer)(!OperatingSystem=*Server*))").Count
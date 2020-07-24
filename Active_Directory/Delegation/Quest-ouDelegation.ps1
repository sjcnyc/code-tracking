#Create Temp folder on root of C drive if it doesn't exist
If (!(Test-Path C:\Temp\)) {New-Item -Path "C:\Temp\" -ItemType Directory -Force}

# --Requires Quest Active Directory Management Tools
Add-PSSnapin Quest.ActiveRoles.ADManagement

#VERY IMPORTANT: Always backup existing ACLs first before making any changes
#This commandlet will show all Security ACL Permissions for a given AD Object
Get-QADObject "OU=Washington,DC=Pentagon,DC=USA,DC=COM" -SecurityMask Dacl | Get-QADPermission | Export-Csv C:\Temp\Root-Permimissions.csv

#This is another way of doing the above. Replace DomainDNSRoot with your Domain name like lab.domain.local
Get-QADPermission -Identity "DomainDNSRoot/" | Export-Csv C:\Temp\Root-Permimissions.csv

#The following will get permissions a User/Group has on all OUs within the domain
$OUs = Get-ADOrganizationalUnit -FILter * | Select-Object DistinguishedName -ExpandProperty DistinguishedName
ForEach ($OU in $OUs) {
    Get-QADPermission -Identity "$OU" -Account "DomainNetBIOSName\jfkennedy"

    #If you wanted to remove those permissions just pipe it like below but remove -whatif parameter
    Get-QADPermission -Identity "$OU" -Account "DomainNetBIOSName\jfkennedy" | Remove-QADPermission -WhatIf
}
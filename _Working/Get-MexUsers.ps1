$ADUserSplat = @{
  Filter     = { (Enabled -eq $True) }
  Properties = 'DisplayName', 'givenName', 'sn', 'Mail', 'sAMAccountName', 'CanonicalName'
}

$getADOrganizationalUnitSplat = @{
  SearchBase = 'OU=Users,OU=MXC,OU=MEX,OU=LA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com'
  Filter     = 'Name -like "Employees" -or Name -like "Non-employees"'
}

$ous = (Get-ADOrganizationalUnit @getADOrganizationalUnitSplat).DistinguishedName

$Users =
foreach ($ou in $ous) {
  Get-ADUser -SearchBase $ou @ADUserSplat | Select-Object 'DisplayName', 'givenName', 'sn', 'Mail', 'sAMAccountName', 'CanonicalName'
}

$Users | Export-Csv -Path C:\Temp\MEX_Users_Enabled_$(Get-Date -f {MMdyyyyhhmm}).csv -NoTypeInformation

# for git sync
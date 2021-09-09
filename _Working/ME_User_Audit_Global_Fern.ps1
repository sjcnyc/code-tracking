$ADUserSplat = @{
  Filter     = { (Enabled -eq $True) }
  Properties = 'sAMAccountName', 'givenName', 'sn', 'enabled', 'CanonicalName', 'whenCreated', 'whenChanged', 'LastLogonTimeStamp'
}

$Users = @()

$getADOrganizationalUnitSplat = @{
  SearchBase = 'OU=Tier-2,DC=me,DC=sonymusic,DC=com'
  Filter     = 'Name -like "Employees" -or Name -like "Non-employees" -or Name -like "LOH"'
}

$ous = (Get-ADOrganizationalUnit @getADOrganizationalUnitSplat).DistinguishedName

$Users =
foreach ($ou in $ous) {
  Get-ADUser -SearchBase $ou @ADUserSplat |
  Select-Object 'sAMAccountName', 'givenName', 'sn', 'enabled', 'CanonicalName', 'whenCreated', 'whenChanged', @{n = 'LastLogon'; e = { [DateTime]::FromFileTime($_.LastLogonTimeStamp) } }
}

$Users | Export-Csv -Path D:\Temp\ME_Users_Global_$(Get-Date -f {MMdyyyyhhmm}).csv -NoTypeInformation
Write-Output "Total User Count: $($Users.Count)"
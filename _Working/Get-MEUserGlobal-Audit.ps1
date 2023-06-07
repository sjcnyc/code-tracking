$ADUserSplat = @{
  Filter     = '*' # { (Enabled -eq $True) }
  Properties = 'sAMAccountName', 'userPrincipalName', 'givenName', 'sn', 'enabled', 'CanonicalName', 'whenCreated', 'whenChanged', 'LastLogonTimeStamp'
}

$Users = @()

$getADOrganizationalUnitSplat = @{
  SearchBase = 'OU=Tier-2,DC=me,DC=sonymusic,DC=com'
  Filter     = 'Name -like "Employee" -or Name -like "Non-employee" -or Name -like "LOH" -or Name -like "LOA" -and Enabled -eq $true'
}

$ous = (Get-ADOrganizationalUnit @getADOrganizationalUnitSplat).DistinguishedName

$Users =
foreach ($ou in $ous) {
  $selectObjectSplat = @{
    Property = 'sAMAccountName', 'userPrincipalName', 'givenName', 'sn', 'enabled', 'CanonicalName', 'whenCreated', 'whenChanged', @{n = 'LastLogon'; e = { [DateTime]::FromFileTime($_.LastLogonTimeStamp) } }
  }

  Get-ADUser -SearchBase $ou @ADUserSplat | Select-Object @selectObjectSplat
}

$Users | Export-Csv -Path C:\Temp\ME_Users_Global_$(Get-Date -f {MMdyyyyhhmm}).csv -NoTypeInformation
Write-Output "Total User Count: $($Users.Count)"

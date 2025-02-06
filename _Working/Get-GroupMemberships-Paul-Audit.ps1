$ADUserSplat = @{
    Filter     = '*' # { (Enabled -eq $True) }
    Properties = 'SamAccountName', 'Mail', 'Name', 'StreetAddress', 'City', 'Country', 'Company', 'Department', 'Title', 'Manager', 'EmployeeType', 'lastLogonTimestamp', 'Enabled', 'canonicalName'

  }

  $Users = @()

  $getADOrganizationalUnitSplat = @{
    SearchBase = 'OU=Tier-2,DC=me,DC=sonymusic,DC=com'
    Filter     = 'Name -like "Employee" -or Name -like "Non-employee" -or Name -like "LOH" -or Name -like "LOA"'
  }

  $ous = (Get-ADOrganizationalUnit @getADOrganizationalUnitSplat).DistinguishedName

  $Users =
  foreach ($ou in $ous) {
    $selectObjectSplat = @{
      Property = 'SamAccountName', 'Mail', 'Name', 'StreetAddress', 'City', 'Country', 'Company', 'Department', 'Title', 'Manager', 'EmployeeType', @{n = 'LastLogonTimeStamp'; e = { [DateTime]::FromFileTime($_.LastLogonTimeStamp) } }, 'Enabled', 'canonicalName'
    }

    Get-ADUser -SearchBase $ou @ADUserSplat | Select-Object @selectObjectSplat
  }

  $Users | Export-Csv -Path C:\Temp\ME_Users_Global_Mod_$(Get-Date -f {MMdyyyyhhmm}).csv -NoTypeInformation
  Write-Output "Total User Count: $($Users.Count)"

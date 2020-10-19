@{n = 'ParentContainer'; e = { ($_.distinguishedName -Split ",")[1].Replace("OU=", "").Replace("CN=", "") } }

$ADUserSplat = @{
  Filter     = "*"
  SearchBase = "OU=Tier-2,DC=me,DC=sonymusic,DC=com"
  Properties =
              "SamAccountName",
              "EmailAddress",
              "Name",
              "StreetAddress",
              "City",
              "Country",
              "Company",
              "Department",
              "Title",
              "Manager",
              "CN",
              "CanonicalName",
              "LastLogonDate",
              "PasswordExpired",
              "PasswordLastSet",
              "PasswordNeverExpires",
              "PasswordNotRequired",
              "Enabled"
}

Get-ADUser @ADUserSplat | Select-Object $ADUserSplat.Properties | Export-Csv D:\Temp\Tier2_Users_5.csv -NoTypeInformation
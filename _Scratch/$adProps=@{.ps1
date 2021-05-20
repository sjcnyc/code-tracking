$adProps = @{
  SearchBase = "OU=Users,OU=MIL,OU=ITA,OU=EU,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
  Properties = "DisplayName", "Street", "City", "State", "PostalCode", "c", "Co", "Country"
  Filter     = "*"
}

Get-ADUser @adProps | Export-Csv C:\Temp\ITL.csv -NoTypeInformation
function Get-NameFromDN{
  param
  (
    [System.String]
    $DN
  )

  return ($DN.replace('\','') -split ',*..=')[6]
}

Get-NameFromDN  'CN=Connealy\, Sean,OU=Employees,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com'
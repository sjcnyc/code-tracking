function Get-NameFromDN{
  param
  (
    [System.String]
    $DN
  )
  
  return ($DN.replace('\','') -split ',*..=')[2]
} 

Get-NameFromDN  'CN=Group\, Name I Want,OU=Group Container,DC=corp,DC=test,DC=local'
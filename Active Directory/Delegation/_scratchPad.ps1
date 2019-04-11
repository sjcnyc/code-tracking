('OU=Wkstn_TOR, OU=Wkstn_Canada, OU=Wkstn_NA, OU=Workstations, DC=me, DC=sonymusic, DC=com' -split ',*..=')[1]

('OU=Wkstn_WAR, OU=Wkstn_Poland, OU=Wkstn_EU, OU=Workstations, DC=me,DC=sonymusic,DC=com' -split ',')[3].Substring(9)

'OU=Wkstn_WAR, OU=Wkstn_Poland, OU=Wkstn_EU, OU=Workstations, DC=me,DC=sonymusic,DC=com' -match '^OU=(?<WAR>[^,]*)'

'OU=MTL1,OU=CORP,DC=FX,DC=LAB' -match '(?<=(^OU=))\w*(?=(,))'

Get-ADOrganizationalUnit 'OU=NYC,DC=bmg,DC=bagint,DC=com' | Select-Object -Property city

Get-ADOrganizationalUnit -Server 'me.sonymusic.com' 'OU=Wkstn_Canada, OU=Wkstn_NA, OU=Workstations, DC=me, DC=sonymusic, DC=com' -Filter * | Select-Object -Property City

((Get-ADOrganizationalUnit -Server 'me.sonymusic.com' -SearchBase 'OU=Wkstn_Canada, OU=Wkstn_NA, OU=Workstations, DC=me, DC=sonymusic, DC=com' -SearchScope Subtree -Filter * |
Select-Object -Property City, Name, distinguishedname).Where{-not [string]::IsNullOrEmpty($_.City)}).City

$sourceACL = Get-Acl 'AD:\OU=WST,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com'
$sourceGroup = 'USA-GBL-L Workstation Administration (ADS)'

$sourceACL |
Select-Object -ExpandProperty Access |
Where-Object -FilterScript {
  $_.IdentityReference -like "*$sourceGroup*" -and $_.IsInherited -eq $false
}

$domain = [adsi] 'LDAP://OU=Wkstn_TOR,OU=Wkstn_Canada,OU=Wkstn_NA,OU=Workstations,DC=me,DC=sonymusic,DC=com'
$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$Searcher.SearchRoot = $domain
$Searcher.SearchScope = 'subtree'

$Searcher.Filter = '(objectCategory=organizationalUnit)'

$null = $Searcher.PropertiesToLoad.Add('l')
$null = $Searcher.PropertiesToLoad.Add('Name')
$null = $Searcher.PropertiesToLoad.Add('DistinguishedName')

<# $results = $Searcher.FindAll() |
Select-Object -ExpandProperty properties |
Where-Object -FilterScript {
  ![string]::IsNullOrEmpty($_.l)
} #>



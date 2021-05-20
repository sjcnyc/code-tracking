$tier2Users = Get-ADOrganizationalUnit -Filter 'Name -like "Users"' -SearchBase "OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com" -Server 'me.sonymusic.com' -Properties CanonicalName |
    Select-Object Name, DistinguishedName, CanonicalName | Sort-Object CanonicalName

foreach ($userCategory in $tier2Users) {
    $results = Get-ADOrganizationalUnit -SearchScope Subtree -SearchBase $userCategory.DistinguishedName -Server 'me.sonymusic.com' -Properties CanonicalName -Filter * | Select-Object DistinguishedName, CanonicalName
    foreach ($result in $results) {
        $PSObj = [pscustomobject][Ordered]@{
            Name = $result.CanonicalName.Replace("me.sonymusic.com/", "")
            Dn   = $result.DistinguishedName
        }
        $PSObj
    }
}
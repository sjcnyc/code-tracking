using namespace System.Collections.Generic

$PSList = [List[psobject]]::new()

$getADOrganizationalUnitSplat = @{
  Filter      = '*'
  Properties  = 'DistinguishedName', 'CanonicalName'
  #SearchScope = 'OneLevel'
  Server      = 'me.sonymusic.com'
}
$OUs = Get-ADOrganizationalUnit @getADOrganizationalUnitSplat

foreach ($OU in $OUs) {
  $PSObject = [pscustomobject]@{
    'OrganizationalUnit' = $OU.CanonicalName
    'UserCount'          = (Get-ADUser -SearchBase $OU.DistinguishedName -Filter * -Server 'me.sonymusic.com').Count
  }
  [void]$PSList.Add($PSObject)
}

$PSList
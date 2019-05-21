function Recurse-OU ([string]$dn, $level = 1) {

  if ($level -eq 1) { $dn }
  Get-ADOrganizationalUnit -filter * -SearchBase $dn -SearchScope OneLevel -Server 'me.sonymusic.com' |
  Sort-Object -Property distinguishedName |
  ForEach-Object {
    $components = ($_.distinguishedname).split(',')
    "$('--' * $level) $($components[0])"
    Recurse-OU -dn $_.distinguishedname -level ($level + 1)
  }

}

Recurse-OU -dn 'OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com' | Out-File c:\temp\ous2.txt
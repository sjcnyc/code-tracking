Get-ADOrganizationalUnit -Filter * |
Select-Object name, @{ n = 'Owner'; e = { (Get-Acl "ActiveDirectory:://RootDSE/$($PSItem.DistinguishedName)").owner } }


     
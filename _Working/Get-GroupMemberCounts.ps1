<# $allgroups = @'
usa-gbl member server administrators
domain admins
'@ -split [environment]::NewLine #>

$allgroups = Get-ADGroup -Filter * -SearchBase 'OU=this,OU=an,OU=example,DC=test,DC=test,DC=com' | Select-Object Name

foreach ($group in $allgroups) {
    [pscustomobject]@{
        Group       = $group.Name
        Membercount = Get-ADGroupMember $group.Name | Where-Object { $_.ObjectClass -eq 'User' } | Measure-Object | Select-Object -ExpandProperty Count
    }
}
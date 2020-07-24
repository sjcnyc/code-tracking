$group = @"
usa-gbl member server administrators
domain admins
"@ -split [environment]::NewLine

foreach ($a_group in $group){
    [pscustomobject]@{
        Group         = $a_group
        Membercount   = get-adgroupmember $a_group -recursive | measure-object | Select-Object -ExpandProperty count
    }
}

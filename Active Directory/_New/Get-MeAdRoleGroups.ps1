$now = Get-Date
$ShortDate = $now.ToShortDateString() -replace "/", ""

$RoleGroups = Get-ADGroup -Filter {Name -like "*-Role"} | Select-Object Name

$PSGroupArray = New-Object System.Collections.ArrayList
$PSArray = New-Object System.Collections.ArrayList

$RoleGroups | ForEach-Object {
    $PSGroupObject = [pscustomobject]@{
        'Group'    = $_.Name
        'Members'  = (Get-ADGroupmember $_.Name | Select-Object -ExpandProperty Name | Out-String).Trim()
        'MemberOf' = (Get-ADprincipalgroupmembership $_.Name | Select-Object -ExpandProperty Name | Out-String).Trim()
    }
    [void]$PSGroupArray.Add($PSGroupObject)
}

foreach ($result in $PSGroupArray) {
    switch ($result.Group) {
        {$_ -like "T0_*"} {$tier = "Tier-0"}
        {$_ -like "T1_*"} {$tier = "Tier-1"}
        {$_ -like "T2_*"} {$tier = "Tier-2"}
        default {$category = ""}
    }
    switch ($result.Group) {
        {$_ -like "*_ADM_*"} {$category = "ADM"}
        {$_ -like "*_SRV_*"} {$category = "SRV"}
        {$_ -like "*_STD_*"} {$category = "STD"}
        {$_ -like "*_STG_*"} {$category = "STG"}
        default {$category = ""}
    }
    switch ($result.Group) {
        {$_ -like "*Service_Desk*"} {$department = "Service Desk"}
        {$_ -like "*Access_Control*"} {$department = "Access Control"}
        {$_ -like "*Global_AD_Ops*"} {$department = "Global AD Ops"}
        {$_ -like "*Local_IS&T*"} {$department = "Local IS&T"}
        default {$department = ""}
    }

    $info = [PSCustomObject]@{
        Group      = $result.Group
        Members    = $result.Members
        MemberOf   = $result.MemberOf
        Tier       = $tier
        Category   = $category
        Department = $department
    }
    [void]$PSArray.Add($info)
}
$PSArray | Out-GridView
#$PSArray | Export-CSV c:\Roles_mod3_$($ShortDate).csv -NoTypeInformation
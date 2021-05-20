$results = import-csv C:\temp\roles.csv

$PSArray = New-Object System.Collections.ArrayList

foreach ($result in $results) {
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
#$PSArray | Out-GridView
$PSArray | Export-CSV c:\temp\Roles_mod.csv -NoTypeInformation




#One column for category like ADM,SRV,STD,STG and one column for dept (Service Desk, Access Control, Global AD Ops, Local IS&T).

# Category: ADM, Department: Service_Desk
# Category: ADM, Department: Access_Control
# Category: ADM, Department: Global_AS_ops
# Category: ADM, Department: Local_IS&T


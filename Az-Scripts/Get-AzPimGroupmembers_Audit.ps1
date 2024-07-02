
$Groups = Get-MgGroup -Filter "startsWith(displayName, 'Az_PIM_')" -ConsistencyLevel eventual -CountVariable countVar -All

$Table =
foreach ($Group in $Groups) {
    $Groupname = $Group.DisplayName
    $Members = (Get-MgGroupMember -GroupId $Group.Id -All).AdditionalProperties.userPrincipalName

    foreach ($member in $members) {

        [PSCustomObject]@{
            Group             = $Groupname
            UserPrincipalName = $member
        }
    }
}

$Table | Export-Csv C:\Temp\PIM_Roles.csv -NoTypeInformation
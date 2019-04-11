$roles = Get-MsolRole | Select-Object *

foreach ($role in $roles) {

    $roleMembers = $role | ForEach-Object {Get-MsolRoleMember -RoleObjectId $_.ObjectId | Select-Object *}

    $object = [PSCustomObject]@{

        'RoleName'        = $role.Name
        'RoleDescription' = $role.Description
        'roleUser'        = ($roleMembers.EmailAddress | Out-String).Trim()
    }
$object | Export-Csv C:\Temp\otherRoleGroups.csv -NoTypeInformation -Append
}
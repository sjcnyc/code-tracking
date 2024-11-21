$connectMgGraphSplat = @{
    NoWelcome             = $true
    ClientId              = '91152ce4-ea23-4c83-852e-05e564545fb9'
    TenantId              = 'f0aff3b7-91a5-4aae-af71-c63e1dda2049'
    CertificateThumbprint = 'c838457e980e940c42d9950fa3b3bd8f05b6e919'
}

Connect-MgGraph @connectMgGraphSplat



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

$Table | Export-Csv C:\Temp\Az_PIM_Roles_$(Get-Date -Format 'MM-dd-yyy').csv -NoTypeInformation
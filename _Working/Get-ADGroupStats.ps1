#region Get AD Group stats
#Specify ADGroup(s) using like
$groupName = 'DAT_ICT*'
$adGroup = Get-ADGroup -Filter { Name -like $groupName} |
Foreach-Object {
    [PSCustomObject]@{
        Group                = $_
        GroupMembers         = Get-ADGroup -Filter { memberOf -eq $_.DistinguishedName }
        UserMembers          = Get-ADUser  -Filter { memberOf -eq $_.DistinguishedName }
        UserMembersRecursive = Get-ADGroup -Filter { memberOf -eq $_.DistinguishedName } |
            ForEach-Object{
                Get-ADGroupMember -Identity $_ -Recursive
            }
        GroupMemberOf        = Get-ADGroup -Filter { members  -eq $_.DistinguishedName }
    }
}

#Get Count of the ADGroup(s)
$adGroupMembersCount = $adGroup |
ForEach-Object{
    [PSCustomObject]@{
        Group                           = $_.Group.Name
        countGroupMembers               = @($_.GroupMembers).Count
        countUserMembers                = @($_.UserMembers).Count
        countUserMembersRecursiveUnique = @($_.UserMembersRecursive | Select-Object -Unique ).Count
        countGroupMembersOf             = @($_.GroupMemberOf).Count
    }
}
#endregion
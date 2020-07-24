Import-Module ActiveDirectory

$root = "AD:\OU=Wkstn_UnitedStates,OU=Wkstn_NA,OU=Workstations,DC=me,DC=sonymusic,DC=com"
$sourceOU = "Wkstn_USA"
$sourceACL = Get-Acl $root.Replace("AD:\", "AD:\OU=$sourceOU,")
$sourceGroup = "NA-USA-Regional-Administrators"

# Hash for the new groups and their OUs
# Construct Group Name from _OU Name
$targetGroups = @{}
$targetGroups.Add("NA-TOR-Regional-Administrators", @("Wkstn_TOR"))

# Get the uniherited ACEs for the $sourceGroup from $sourceOU
$sourceACEs = $sourceACL |
    Select-Object -ExpandProperty Access |
    Where-Object { $_.IdentityReference -match "$($sourceGroup)$" -and $_.IsInherited -eq $False }

# Walk each targetGroup in the hash
foreach ( $g in $targetGroups.GetEnumerator() ) {

    # Get the AD object for the targetGroup
    Write-Output $g.Name
    $group = Get-ADGroup $g.Name
    $identity = New-Object System.Security.Principal.SecurityIdentifier $group.SID

    # Could be multiple ACEs for the sourceGroup
    foreach ( $a in $sourceACEs ) {

        # From from the sourceACE for the ActiveDirectoryAccessRule constructor
        $adRights = $a.ActiveDirectoryRights
        $type = $a.AccessControlType
        $objectType = New-Object Guid $a.ObjectType
        $inheritanceType = $a.InheritanceType
        $inheritedObjectType = New-Object Guid $a.InheritedObjectType

        # Create the new "copy" of the ACE using the target group. http://msdn.microsoft.com/en-us/library/w72e8e69.aspx
        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $identity, $adRights, $type, $objectType, $inheritanceType, $inheritedObjectType

        # Walk each city OU of the target group
        foreach ( $city in $g.Value ) {

            Write-Output "`t$city"
            # Set the $cityOU
            $cityOU = $root.Replace("AD:\", "AD:\OU=$city,")
            # Get the ACL for $cityOU
            $cityACL = Get-ACL $cityOU
            # Add it to the ACL
            $cityACL.AddAccessRule($ace)
            # Set the ACL back to the OU
            Set-ACL -AclObject $cityACL $cityOU
        }
    }
}
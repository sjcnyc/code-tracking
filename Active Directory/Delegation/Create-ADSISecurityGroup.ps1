function New-ADSISecurityGroup {
    param(
        $targetOU,
        $groupName,
        $groupDesc
    )

    $groupType = @{
        Global      = 0x00000002
        DomainLocal = 0x00000004
        Universal   = 0x00000008
        Security    = 0x80000000
    }
    try {
        # Bind to OU
        $ou = [ADSI]"LDAP://$($targetOU)"
        $group = $ou.Create('group', "CN=$($groupName)")
        $group.Put('grouptype', ($groupType.DomainLocal -bor $groupType.Security))
        $group.Put('samaccountname', $groupName)
        $group.Put('description', $groupDesc)
        $group.SetInfo()
    }
    catch {
        $Error[0].Exception
    }
}

New-ADSISecurityGroup -targetOU 'OU=COMP,OU=TST,OU=NYCtest,DC=bmg,DC=bagint,DC=com' -groupName 'USA-GBL-L Workstation Administration (Testing)' -groupDesc 'Security Group for Workstation Administration (Testing)'
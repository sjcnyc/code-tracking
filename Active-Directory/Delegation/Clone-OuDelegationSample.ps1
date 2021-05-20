[Reflection.Assembly]::LoadWithPartialName("Softerra.Adaxes.Adsi")


function GetRolePath($name, $securityRolesPath) {
    # Search Security Roles
    $searcher = $admService.OpenObject($securityRolesPath, $NULL, $NULL, 0)
    $filterPart = [Softerra.Adaxes.Ldap.FilterBuilder]::Create("name", $name)
    $searcher.SearchFilter = "(&(objectCategory=adm-Role)$filterPart)"
    $searcher.PageSize = 500
    $searcher.SearchScope = "ADS_SCOPE_SUBTREE"
    $searcher.ReferralChasing = "ADS_CHASE_REFERRALS_NEVER"
    try {
        $searchResult = $searcher.ExecuteSearch()
        $objects = $searchResult.FetchAll()

        if ($objects.Count -eq 0) {
            Write-Warning "Role $name could not be found"
            return $NULL
        }
        elseif ($objects.Count -gt 1) {
            Write-Warning "Found more than one Security Role with name '$name'."
            return $NULL
        }
        
        return $objects[0].AdsPath
    }
    finally {
        $searchResult.Dispose()
    }
}

function GetGroupSid ($dn) {
    $group = $admService.OpenObject("Adaxes://$dn", $NULL, $NULL, 0)
    $sid = New-Object "Softerra.Adaxes.Adsi.Sid" @($group.Get("objectSID"), 0)

    return $sid
}

function CopyRoleAssignment($sourceRoleName, $sourceGroupDN, $destinationRoleName, $destinationGroupDN) {
    # Connect to Adaxes service
    $admNS = New-Object "Softerra.Adaxes.Adsi.AdmNamespace"
    $admService = $admNS.GetServiceDirectly("localhost")

    # Get source role and destination role paths
    $securityRolesPath = $admService.Backend.GetConfigurationContainerPath("AccessControlRoles")
    $sourceRolePath = GetRolePath $sourceRoleName $securityRolesPath
    $destinationRolePath = GetRolePath $destinationRoleName $securityRolesPath
    if (($sourceRolePath -eq $NULL) -or ($destinationRolePath -eq $NULL)) {
        return
    }

    # Copy source Security Role Assignment

    # Bind to the source Security Role
    $sourceRole = $admService.OpenObject($sourceRolePath, $NULL, $NULL, 0)
    # Bind to the destination Security Role
    $destinationRole = $admService.OpenObject($destinationRolePath, $NULL, $NULL, 0)

    # Get the source and destination group SIDs
    $sourceGroupSid = GetGroupSid $sourceGroupDN
    $destinationGroupSid = GetGroupSid $destinationGroupDN

    foreach ($sourceAssignment in $sourceRole.Assignments) {
        if ($sourceAssignment.Trustee -ne $sourceGroupSid) {
            continue
        }
       
        $assignment = $destinationRole.Assignments.Create()
        $assignment.Trustee = $destinationGroupSid
        $assignment.SetInfo()
        $destinationRole.Assignments.Add($assignment)
        
        foreach ($item in $sourceAssignment.ActivityScopeItems) {
            $scopeItem = $assignment.ActivityScopeItems.Create()
            $scopeItem.BaseObject = $item.BaseObject
            $scopeItem.Type = $item.Type
            $scopeItem.Inheritance = $item.Inheritance
            
            $scopeItem.Exclude = $item.Exclude
            $scopeItem.SetInfo()

            $assignment.ActivityScopeItems.Add($scopeItem)
        }
    }
}

CopyRoleAssignment "Help Desk - User Control" "CN=Help Desk,OU=Groups,OU=Something,DC=domain,DC=com" "Help Desk - Limited - Unlock/Reset" "CN=Help Desk,OU=Groups,OU=Something,DC=domain,DC=com"
Clear-Host

$sourceOU = Get-ADOrganizationalUnit -Identity 'OU=4077.dk,OU=Hosting,DC=mycorp,DC=dk' -Properties nTSecurityDescriptor -ErrorAction Stop
$destOU = Get-ADOrganizationalUnit -Identity 'OU=4204.dk,OU=Hosting,DC=mycorp,DC=dk'-Properties nTSecurityDescriptor -ErrorAction Stop

# You might want to clear the destination ACL of non-inherited ACEs before starting this loop

foreach ($sourceAce in $sourceOU.nTSecurityDescriptor.Access) {
    if ($sourceAce.IsInherited) { continue }
    "---------- SOURCE ACL v ----------"
    $sourceAce
    $identityReference = $null

    #    try
    #    {
    $sourceAccount = $sourceAce.IdentityReference.Translate([System.Security.Principal.NTAccount])
    $newName = $sourceAccount.Value -replace $sourceOU.Name, $destOU.Name
    $identityReference = [System.Security.Principal.NTAccount]$newName
    #    }
    #    catch
    #    {
    # You may want to log an error if you can't translate the SID to User\Group form
    #    }

    $destAce = $destOU.nTSecurityDescriptor.AccessRuleFactory($identityReference,
        $sourceAce.ActiveDirectoryRights,
        $sourceAce.IsInherited,
        $sourceAce.InheritanceFlags,
        $sourceAce.PropagationFlags,
        $sourceAce.AccessControlType,
        $sourceAce.ObjectType,
        $sourceAce.InheritedObjectType)

    "---------- DESTINATION ACL v ----------"
    $destAce

    # This statement will throw an error if the destination identity doesn't exist.
    $destOU.nTSecurityDescriptor.AddAccessRule($destAce)
    Set-ADOrganizationalUnit -instance $destOU
}


#Get-QADObject 'CN=AKL-CGR-L Workstation Administration (local),OU=COMP,OU=CGR,OU=AKL,DC=bmg,DC=bagint,DC=com' -SecurityMask Dacl -sizelimit 0 | Get-QADPermission -Inherited -SchemaDefault
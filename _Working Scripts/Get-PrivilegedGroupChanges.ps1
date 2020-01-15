function Get-PrivilegedGroupChanges {
    param(
        [string]
        $Server = (Get-ADDomainController -Discover | Select-Object -ExpandProperty HostName),

        [int]
        $Days = 200
    )

        $ProtectedGroups = Get-ADGroup -Filter 'AdminCount -eq 1' -Server $Server
        $Members = @()

        foreach ($Group in $ProtectedGroups) {
            $Members += Get-ADReplicationAttributeMetadata -Server $Server -Object $Group.DistinguishedName -ShowAllLinkedValues |
             Where-Object {$_.IsLinkValue} |
             Select-Object @{N='GroupDN';E={$Group.DistinguishedName}}, @{N='GroupName';E={$Group.Name}}, *
        }

        $Members |
            Where-Object {$_.LastOriginatingChangeTime -gt (Get-Date).AddDays(-$Days)}

    }

Get-PrivilegedGroupChanges | Select-Object Groupname,AttributeValue,LastOriginatingChangeTime,Server
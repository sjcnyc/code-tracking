function Copy-GroupMembership {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        # Source user account name
        [Parameter(Mandatory = $true, Position = 0)][string]
        $Source,

        [Parameter(Mandatory = $true, Position = 1)][string[]]
        $Targets,

        [switch]
        $RemoveExisting,

        [System.Management.Automation.CredentialAttribute()]
        [SecureString] $credential
    )
    
    Write-Verbose 'Retrieving source group memberships.'
    $SourceUser = Get-ADUser $Source -Properties memberOf -ea 1
    
    foreach ($Target in $Targets) {

        Write-Verbose "Get group memberships for $($Target)."
        $TargetUser = Get-ADUser $Target -Properties memberOf

        If (!$TargetUser) {
            Write-Warning "Unable to find useraccount $($Target). Skipping!"
        }
        else {
            $List = @{}

            ForEach ($SourceDN In $SourceUser.memberOf) {
                $List.Add($SourceDN, $True)
                $SourceGroup = [ADSI]"LDAP://$SourceDN"

                Write-Verbose "Checking if '$target' is already a member of '$sourceDN'."
                If ($SourceGroup.IsMember("LDAP://" + $TargetUser.distinguishedName) -eq $False) {
                    if ($pscmdlet.ShouldProcess($Target, "Add to group '$SourceDN'")) {
                        Write-Verbose "Adding $($target) to this group."
                        try {
                            Add-ADGroupMember -Identity $SourceDN -Members $Target -Credential $credential
                        }
                        catch {
                            $_
                        }
                    }
                }
                else {
                    Write-Verbose "$($Target) is already a member of this group."
                }
            }

            If ($RemoveExisting) {
                Write-Verbose 'Entering removal phase.'
                ForEach ($TargetDN In $TargetUser.memberOf) {
                    Write-Verbose "Checking if $($Target) is a member of $($TargetDN)."
                    If ($List.ContainsKey($TargetDN) -eq $False) {
                        if ($pscmdlet.ShouldProcess($Target, "Remove from group $($TargetDN)")) {
                            Write-Verbose "Removing $($Target) from this group."
                            Remove-ADGroupMember $TargetDN $Target -Credential $credential
                        }
                    }
                    else {
                        Write-Verbose "$($Target) is not a member of this group."
                    }
                }
            }
        }
    }
}

Copy-GroupMembership -Source "T1_SRV_NA_USA_GBL_JMP_G_SrvRDU" -Targets "T1_SRV_NA_USA_GBL_AzureVDI_G_SrvRDU" -WhatIf
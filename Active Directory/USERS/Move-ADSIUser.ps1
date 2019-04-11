
#Move-ADSIUser -Identity 'sc_testuser' -Destination "OU=MNET dest"

#Move-ADSIUser -Identity 'sc_testuser' -Destination "OU=MNET dest" -Credential (Get-Credential)


function Move-ADSIUser {
    [CmdletBinding()]
    [OutputType('System.DirectoryServices.AccountManagement.UserPrincipal')]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Identity,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$DomainName,
        $Destination
    )

    BEGIN {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $ContextSplatting = @{ ContextType = "Domain" }

        if ($PSBoundParameters['Credential']) { $ContextSplatting.Credential = $Credential }
        if ($PSBoundParameters['DomainName']) { $ContextSplatting.DomainName = $DomainName }

        $Context = New-ADSIPrincipalContext @ContextSplatting
    }
    PROCESS {
        if ($Identity) {
            $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Identity)
            $NewDirectoryEntry = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList "LDAP://$Destination"
            $User.GetUnderlyingObject().psbase.moveto($NewDirectoryEntry)
            $User.Save()
        }
    }
}
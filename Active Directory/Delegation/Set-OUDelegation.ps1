function Set-OUDelegation {
    [CmdletBinding()]
    param(

        [adsi]$sourceOU = "LDAP://OU=WST,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com",
        [string]$sourceGroup = "BMG\USA-GBL-L Workstation Administration (ADS)",
        [adsi]$targetOU = "LDAP://OU=WST,OU=TST,OU=NYCtest,DC=bmg,DC=bagint,DC=com",
        [string]$targetGroup = 'BMG\USA-GBL-L Workstation Administration (Testing)'
    )

    try {
        $sourceACL = $sourceOU.psbase.ObjectSecurity.Access | Where-Object { $_.IdentityReference -like "$sourceGroup" }
        Write-Output ($sourceACL | out-string)

        $targetACL = $sourceACL |
            ForEach-Object {
            New-Object -TypeName System.DirectoryServices.ActiveDirectoryAccessRule -ArgumentList ([System.Security.Principal.NTAccount]$targetGroup),
            $_.ActiveDirectoryRights,
            $_.AccessControlType,
            $_.ObjectType,
            $_.InheritanceType,
            $_.InheritedObjectType
        }

        $targetOU.psbase.Options.SecurityMasks = [System.DirectoryServices.SecurityMasks]::Dacl
        $targetOU.psbase.CommitChanges()
        Start-Sleep -Seconds '1'

        $targetACL | ForEach-Object { $targetOU.psbase.ObjectSecurity.AddAccessRule($_) }
        $targetOU.psbase.CommitChanges()

        Write-Output "After update with $targetGroup"
        Write-Output ($targetOU.psbase.ObjectSecurity.Access | Where-Object { $_.IdentityReference -like $targetGroup } | out-string)
    }
    catch {
        "Error was $_"
        $line = $_.InvocationInfo.ScriptLineNumber
        "Error was in Line $line"
    }
}

Set-OUDelegation
function Copy-JDOrganizationalUnit {
    <#
.SYNOPSIS
    The script copies an OU structure from one OU to another. The destination OU must already be created.
.EXAMPLE
    Copy-JDOrganizationalUnit -SourcePath "OU=HAB,OU=SE,OU=Sites,DC=lucernepublishing,DC=local" -DestinationPath "OU=HEL,OU=FI,OU=Sites,DC=lucernepublishing,DC=local" -Verbose
.PARAMETER SourceOU
    Plain name of the source OU to copy the structure from.
.PARAMETER DestinationOU
    Plain name of the destination OU to replicate the structure to.
.PARAMETER ProtectOU
    Sets the flag ProtectOUFromAccidentialDeletion
.NOTES
    File Name: Copy-JDOrganizationalUnit
    Author   : Johan Dahlbom, johan[at]dahlbom.eu
    Blog     : 365lab.net
    The script are provided “AS IS” with no guarantees, no warranties, and they confer no rights.
#>
 
    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'http://www.365lab.net/')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {Get-ADOrganizationalUnit -Identity $_})]
        [string]$SourcePath,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {Get-ADOrganizationalUnit -Identity $_})]
        [string]$DestinationPath,
        [switch]$ProtectOU
    )
    Write-Verbose "Copying structure from $SourcePath to $DestinationPath..."
    Get-ADOrganizationalUnit -SearchBase $SourcePath -Filter {Distinguishedname -ne $SourcePath} -Properties canonicalname| Select-Object DistinguishedName, canonicalname, Name  | Sort-Object -Property CanonicalName | ForEach-Object {
        try {
            $NewOU = @{
                Path                            = $_.DistinguishedName.replace("OU=$($Name),", '').Replace("$SourcePath", "$DestinationPath")
                Name                            = $_.Name
                ProtectedFromAccidentalDeletion = $ProtectOU
            }
            New-ADOrganizationalUnit @NewOU -ErrorAction Stop
            Write-Verbose "Created OU OU=$Name,$DestPath"
        } catch {
            Write-Warning "Error with creating OU=$Name,$DestPath`r`n$_"
        }
    }
}

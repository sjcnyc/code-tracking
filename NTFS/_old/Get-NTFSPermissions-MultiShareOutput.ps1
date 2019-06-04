#requires -Version 2 -Modules pdftools
#requires -PSSnapin Quest.ActiveRoles.ADManagement
Function Remove-InvalidFileNameChars {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Name
    )
    [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object -Process {$Name = $Name.replace($_ , '-')}
    return ($Name)
}

function Get-NTFSPermissions {
    [cmdletbinding()]
    param (
        [parameter(mandatory = $true, position = 0 , ValueFromPipeline = $true)]$ShareName,
        [parameter(mandatory = $true, position = 1)]$DomainName,
        [parameter(mandatory = $false)][switch]$GroupsOnly
    )

   # $Output = @()
    foreach ($Share in $ShareName) {
        $ACLs = Get-Acl -Path $Share
        foreach ($ACL in $ACLs) {
            foreach ($AccessRight in $ACL.Access) {
                if ($AccessRight.IdentityReference -notlike 'BUILTIN\*') {
                    $ObjectGroup = [pscustomobject]@{
                        'DirectoryPath' = $Share
                        'Identity' = $AccessRight.IdentityReference
                        'SystemRights' = $AccessRight.FileSystemRights
                        'SystemRightsType' = $AccessRight.AccessControlType
                        'IsInherited' = $AccessRight.IsInherited
                        'InheritanceFlags' = $AccessRight.InheritanceFlags
                        'RulesProtected' = $ACL.AreAccessRulesProtected
                    }
                }
                if ($GroupsOnly -eq $true) {$ObjectGroup} else {
                    $Groups = $ObjectGroup | Select-Object -ExpandProperty 'Identity' -ErrorAction SilentlyContinue
                    foreach ($Group in $Groups) {
                        if ($Group -like "$DomainName\*") {
                            $grp = $Group.tostring()
                            $gp = $grp.replace("$DomainName\", '')
                            $Users = Get-QADGroupMember -Identity $gp -Indirect -SizeLimit 0 -ErrorAction SilentlyContinue
                            foreach ($User in $Users) {
                                $Usr = $User | Select-Object -ExpandProperty 'samaccountname'
                                $fname = $User | Select-Object -ExpandProperty 'name'
                                $ObjectUser = [pscustomobject]@{
                                    'DirectoryPath' = $Share
                                    'Group' = $gp
                                    'SystemRights' = $ObjectGroup.SystemRights
                                    'SystemRightsType' = $ObjectGroup.SystemRightsType
                                    'IsInherited' = $ObjectGroup.IsInherited
                                    'InheritanceFlags' = $ObjectGroup.InheritanceFlags
                                    'RulesProtected' = $ObjectGroup.RulesProtected
                                    'UserName' = $Usr
                                    'Name' = $fname
                                }
                                $ObjectUser
                            }
                        }
                    }
                }
            }
        }
    }
}

@"
\\usnaspwfs01\share$\A&R
"@ -split [environment]::NewLine |

ForEach-Object -Process {

    Get-NTFSPermissions -ShareName $_ -DomainName BMG |

        Export-Csv -Path C:\temp\SecurityReport_NTFS2.csv -NoTypeInformation -Append
}

# Export-Csv -Path 'C:\temp\_poshReports\$Name.csv' -NoTypeInformation
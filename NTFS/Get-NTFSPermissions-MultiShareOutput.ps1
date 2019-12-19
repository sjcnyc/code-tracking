#requires -Version 2 -Modules pdftools
function Remove-InvalidFileNameChars {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Name
    )
    [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object -Process { $Name = $Name.replace($_ , '-') }
    return ($Name)
}

function Get-NTFSPermissions {
    [cmdletbinding()]
    param (
        [parameter(mandatory = $true, position = 0 , ValueFromPipeline = $true)]$ShareName,
        [parameter(mandatory = $true, position = 1)]$DomainName,
        [parameter(mandatory = $false)][switch]$GroupsOnly
    )

    $Domain = "$DomainName".ToUpper()

    foreach ($Share in $ShareName) {
        $ACLs = Get-Acl -Path $Share
        foreach ($ACL in $ACLs) {
            foreach ($AccessRight in $ACL.Access) {
                if ($AccessRight.IdentityReference -notlike 'BUILTIN\*' -and $AccessRight.IdentityReference -ne "ME\USA-GBL Member Server Administrators" -and $AccessRight.IdentityReference -ne "ME\USA-GBL IS&T All Share Access") {
                    $ObjectGroup = [pscustomobject]@{
                        'DirectoryPath'    = $Share
                        'Identity'         = $AccessRight.IdentityReference
                        'SystemRights'     = $AccessRight.FileSystemRights
                        'SystemRightsType' = $AccessRight.AccessControlType
                        'IsInherited'      = $AccessRight.IsInherited
                        'InheritanceFlags' = $AccessRight.InheritanceFlags
                        'RulesProtected'   = $ACL.AreAccessRulesProtected
                    }
                }
                if ($GroupsOnly -eq $true) { $ObjectGroup } else {
                    $Groups = $ObjectGroup | Select-Object -ExpandProperty 'Identity' -ea 0
                    foreach ($Group in $Groups) {
                        if ($Group -like "$($Domain)\*") {
                            $grp = $Group.tostring()
                            $gp = $grp.replace("$($Domain)\", '')
                            $Users = Get-ADGroupMember -Server "$($Domain).sonymusic.com" -Identity $gp  -Recursive -ea 0
                            foreach ($User in $Users) {
                                $Usr = $User | Select-Object -ExpandProperty 'sAMAccountName'
                                $fname = $User | Select-Object -ExpandProperty 'Name'
                                $ObjectUser = [pscustomobject]@{
                                    'DirectoryPath'    = $Share
                                    'Group'            = $gp
                                    'SystemRights'     = $ObjectGroup.SystemRights
                                    'SystemRightsType' = $ObjectGroup.SystemRightsType
                                    'IsInherited'      = $ObjectGroup.IsInherited
                                    'InheritanceFlags' = $ObjectGroup.InheritanceFlags
                                    'RulesProtected'   = $ObjectGroup.RulesProtected
                                    'UserName'         = $Usr
                                    'Name'             = $fname
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
\\Storage.me.sonymusic.com\data$\RMG_Masters
"@ -split [environment]::NewLine |

ForEach-Object -Process {

    Get-NTFSPermissions -ShareName $_ -DomainName me |

    Export-Csv -Path d:\temp\SecurityReport_NTFS4.csv -NoTypeInformation -Append
}

# Export-Csv -Path 'C:\temp\_poshReports\$Name.csv' -NoTypeInformation
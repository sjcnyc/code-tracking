#requires -Version 2
#requires -PSSnapin Quest.ActiveRoles.ADManagement
function Get-NTFSPermissions {
    [cmdletbinding()]
    param (
        [parameter(mandatory = $true, position = 0, ValueFromPipeline = $true)]$ShareName,
        [parameter(mandatory = $true, position = 1)]$DomainName,
        [parameter(mandatory = $false)][switch]$GroupsOnly
    )
    $Output = @()
    foreach ($Share in $ShareName) {
        $ACLs = Get-Acl -Path $Share
        foreach ($ACL in $ACLs) {
            foreach ($AccessRight in $ACL.Access) {
                if ($AccessRight.IdentityReference -notlike 'BUILTIN\*') {
                    $objGroup = [pscustomobject]@{
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
                    $Groups = $objGroup | Select-Object -ExpandProperty 'Identity' -ErrorAction SilentlyContinue
                    foreach ($Group in $Groups) {
                        if ($Group -like "$DomainName\*") {
                            $grp = $Group.tostring()
                            $gp = $grp.replace("$DomainName\", '')
                            $Users = Get-QADGroupMember -Identity $gp -ErrorAction SilentlyContinue -SizeLimit 0
                            foreach ($User in $Users) {
                                $Usr = $User | Select-Object -ExpandProperty 'samaccountname'
                                $fname = $User | Select-Object -ExpandProperty 'name'
                                $objUser = [pscustomobject]@{
                                    'DirectoryPath' = $Share
                                    'Group' = $gp
                                    'SystemRights' = $objGroup.SystemRights
                                    'SystemRightsType' = $objGroup.SystemRightsType
                                    'IsInherited' = $objGroup.IsInherited
                                    'InheritanceFlags' = $objGroup.InheritanceFlags
                                    'RulesProtected' = $objGroup.RulesProtected
                                    'UserName' = $Usr
                                    'Name' = $fname
                                }
                                $objUser
                            }
                        }
                    }
                }
            }
        }
    }
}



<#Get-ChildItem -Path '\\storage\data$\vsto_deploy' -Directory -Recurse  | Select-Object fullname | 
    ForEach-Object { $_.fullname | Get-NTFSPermissions -DomainName BMG } #| Sort-Object | Export-Csv C:\temp\_poshReports\fin5.csv -NoTypeInformation
# Out-PTSPDF -Path C:\temp\_poshReports\SecurityReport1.pdf -FontSize 8 -AutoSize#>

Get-NTFSPermissions -ShareName '\\storage\mactech$\Backups' -DomainName BMG -GroupsOnly
function Get-NTFSPermissionsMSAD {
    #Requires –Modules ActiveDirectory
    [cmdletbinding()]
    param (
        [parameter(mandatory = $true, position = 0)]$ShareName,
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
                if ($GroupsOnly -eq $true) {
                    $ObjGroup
                }
                else {
                    $Groups = $ObjGroup | Select-Object -ExpandProperty 'Identity'
                    foreach ($Group in $Groups) {
                        if ($Group -like "$DomainName\*") {
                            $grp = $Group.tostring()
                            $gp = $grp.replace("$DomainName\", '')
                            $Users = Get-ADGroupMember -Recursive -Identity $gp
                            foreach ($User in $Users) {
                                $Usr = $User | Select-Object -expandproperty 'samaccountname'
                                $fname = $user | Select-Object -ExpandProperty 'name'

                                $objUser = [pscustomobject]@{
                                    'DirectoryPath' = $Share
                                    'Group' = $gp
                                    'SystemRights' = $ObjGroup.SystemRights
                                    'SystemRightsType' = $ObjGroup.SystemRightsType
                                    'IsInherited' = $ObjGroup.IsInherited
                                    'InheritanceFlags' = $ObjGroup.InheritanceFlags
                                    'RulesProtected' = $ObjGroup.RulesProtected
                                    'UserName' = $Usr
                                    'Name' = $fname
                                }
                                $ObjUser
                            }
                        }
                    }
                }
            }
        }
    }
}

$comps = @"
\\storage\data$\FIN_ReleasePL
\\storage\data$\Project PL_Taskmaster Upload Files
"@ -split [environment]::NewLine

foreach ($comp in $comps) {
    Get-NTFSPermissionsMSAD -ShareName $comp -DomainName BMG -GroupsOnly | Export-Csv c:\temp\report001.csv -NoTypeInformation
}

#$output  | Sort-Object group | Out-PTSPDF -Path C:\temp\_poshReports\Vold.pdf -FontSize 8 -AutoSize
# | Export-Csv C:\TEMP\
#$output | Sort-Object group #| Export-Csv $poshreports\Report_finance11_share.csv -NoTypeInformation
#$($shortName).csv -NoTypeInformation

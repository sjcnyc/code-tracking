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
                if ($AccessRight.IdentityReference -notlike 'BUILTIN\*' -and $AccessRight.IdentityReference -ne "ME\USA-GBL Member Server Administrators") {
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
                if ($GroupsOnly -eq $true) {
                    $ObjectGroup
                } else {
                    $Groups = $ObjectGroup | Select-Object -ExpandProperty 'Identity' -ea 0
                    foreach ($Group in $Groups) {
                        if ($Group -like "$($Domain)\*") {
                            $grp = $Group.tostring()
                            $gp = $grp.replace("$($Domain)\", '')
                            $Users = Get-QADGroupMember -Identity $gp -Indirect -ea 0 -SizeLimit 0
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

$Folders= @"
\\storage.me.sonymusic.com\data$\GHUB_Development
"@ -split [environment]::NewLine


#$Folders = (Get-ChildItem -Directory \\storage.me.sonymusic.com\data$).Fullname

foreach ($Folder in $Folders) {

    Get-NTFSPermissions -ShareName $Folder -DomainName me |
    Select-Object DirectoryPath, Group, Username |
    Export-Csv D:\Temp\ShareReport_Data_users_full4.csv -Append
}



#Get-NTFSPermissions -ShareName "\\storage.me.sonymusic.com\data$\ACCT" -DomainName me -GroupsOnly
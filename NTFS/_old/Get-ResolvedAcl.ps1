function Get-ResolvedAcl
{
    [cmdletBinding(SupportsShouldProcess=$false)]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string]
        $Path
    )
    
    function Get-ADNestedGroupMember 
    {
       param
       (
         [System.Object]
         $Group
       )

        Get-QADGroupMember $Group -Indirect | ForEach-Object {
            $ADObjectName = $_.name
            switch ($_.ObjectClass) {
                'group' {
                    Get-ADNestedGroupMember -Group $ADObjectName
                }
                'user' {
                    @{UserName=$ADObjectName;Group=$Group}
                }
            }
        }
    }
    
    Import-Module -Name ActiveDirectory
    
    (Get-Acl -Path $Path).Access  | ForEach-Object {
        [string]$Trustee = $_.IdentityReference
        $UserDomain = $Trustee.Split('\')[0]
        $SamAccountName = $Trustee.Split('\')[1]
        $ADObject = Get-ADObject -Filter ('SamAccountName -eq "{0}"' -f $SamAccountName)
        switch ($ADObject.ObjectClass) {
            'group' {
                $NestedUser = Get-ADNestedGroupMember -Group $SamAccountName
                if ($NestedUser) {
                    foreach ($User in $NestedUser) {
                        $UserName = '{0}\{1}' -f $UserDomain, $User.UserName
                        $GroupName = $User.Group
                        @{
                            UserName=$UserName;
                            GroupName=$GroupName;
                            DirectAccess=$false;
                            FileSystemRights=$_.FileSystemRights;
                            AccessControlType=$_.AccessControlType
                        }
                    }
                }
            }
            'user' {
                @{
                    UserName=$Trustee;
                    GroupName='';
                    DirectAccess=$true;
                    FileSystemRights=$_.FileSystemRights;
                    AccessControlType=$_.AccessControlType
                }
            }
        }
    }
}
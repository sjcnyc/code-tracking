Import-Module -Name ActiveDirectory

function Connect-HomeDrives {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [string]$Domain = 'BMG',
        # [string]$SearchBase = 'OU=Employees,OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com',
        [string]$Server = '\\Storage.bmg.bagint.com\home$',
        [string]$userName
    )

    $UserList = Get-ADUser -Identity $userName -Properties HomeDirectory |
        Where-Object {$_.HomeDirectory -eq $null} | ForEach-Object {$_.SamAccountName}

    if ($Userlist -ne $null) {

        ForEach ($User in $UserList) {

            $HomeFolderPath = "$Server\$User"

            #Create home folder for user
            if (-Not (Test-Path -Path $HomeFolderPath)) {

                $null = New-Item -Path $HomeFolderPath -itemtype Directory -force
                Write-Verbose -Message 'Created: '; Write-Verbose -Message "$Server\$User"
            }

            $Acl = Get-Acl -Path $HomeFolderPath
            $Ace = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList ("$Domain\$User", 'Modify, ChangePermissions', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
            $Acl.AddAccessRule($Ace)
            Set-Acl -Path $HomeFolderPath -AclObject $Acl
            Write-Verbose -Message 'Applying ACL to :'; Write-Verbose -Message "$HomeFolderPath"

            #Connect home folder in AD as disk H:
            Set-ADUser -Identity $User -HomeDrive 'H:' -HomeDirectory $HomeFolderPath
            Write-Verbose -Message 'Set home drive for user: '; Write-Verbose -Message "$User"
        }
    }

    else { Write-Verbose -Message 'All homedrives are present.' }
}
#requires -Version 2

<#
.SYNOPSIS
    This Script can help you to create several folders, and assign appropriate permission to each folder.
.DESCRIPTION
	This Script can help you to create several folders, and assign appropriate permission to each folder.
.PARAMETER  Path
	Indicate the location, where these folders will be created.
.PARAMETER  UserList
	Indicate a TXT file, which contain a name list of several users, one Name each line. Script will create folder for these users.
.PARAMETER	FullControlMember
	Indicate the users or groups, who have the permission to access each user’s folder.
	Domain admins and system account will be the default value, whatever -FullControlMember be chosen or not. This parameter is optional.
.EXAMPLE
    .\CreateHomeFolder.ps1 -Path "c:\test" -UserList "c:\list.txt” -FullControlMember "file admin","fileadmins"

 	This command will to create home folders for several users. Grant the exact user,
	user “File Admin” and group “FileAdmins” Full control permission to this folders.
.LINK
	http://msdn.microsoft.com/en-us/library/ms147785(v=vs.90).aspx
#>

Function New-HomeFolders {
    param
    (
        [String]$Path,
        [String]$UserList,
        [String[]]$FullControlMember
    )

    $Users = @()
    $Results = @()
    Import-Module ActiveDirectory
    if (-not (Test-Path $Path)) {
        write-error	-Message "Cannot find path '$Path' because it does not exist."
        return
    }
    if (-not (Test-Path $UserList)) {
        write-error	-Message "Cannot find  '$UserList' because it does not exist."
        return
    }
    else {
        $Users = Get-Content $UserList
        #$users = '_test00001'
    }
    #Check whether the input AD member is correct
    if ($FullControlMember) {
        $FullControlMember|ForEach-Object {
            if (-not(Get-ADObject -Filter 'Name -eq $_')) {
                $FullControlMember = $FullControlMember -notmatch $_; Write-Error -Message "Cannot find an object with name:'$_'"
            }
        }
    }
    $FullControlMember += 'NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators'

    foreach ($User in $Users) {
        $HomeFolderACL = Get-Acl $Path
        $HomeFolderACL.SetAccessRuleProtection($true, $false)
        $Result = New-Object PSObject
        $Result|Add-Member -MemberType NoteProperty -Name 'Name' -Value $User
        if (Get-ADUser -Filter 'Name -eq $User') {
            New-Item -ItemType directory -Path "$Path\$User"|Out-Null
            #set acl to folder
            $FCList = $FullControlMember + $User
            $FCList|ForEach-Object {
                $ACL = New-Object System.Security.AccessControl.FileSystemAccessRule($_, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
                $HomeFolderACL.AddAccessRule($ACL)
            }
            Set-Acl -Path "$Path\$User" $HomeFolderACL
            $Result|Add-Member -MemberType NoteProperty -Name 'IsCreated' -Value 'Yes'
            $Result|Add-Member -MemberType NoteProperty -Name 'Remark' -Value 'N/A'
        }
        else {
            $Result|Add-Member -MemberType NoteProperty -Name 'IsCreated' -Value 'No'
            $Result|Add-Member -MemberType NoteProperty -Name 'Remark' -Value "Cannot fine an object with name:'$User'"
        }
        $Results += $Result
    }
    #Generate a report
    $Results|Export-Csv -NoTypeInformation -Path 'c:\temp\Report.csv'
    if ($?) {Write-Host "Please check the report for detail: 'c:\temp\Report.csv'"}
}
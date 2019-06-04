<#
    .SYNOPSIS
        Add, Change or Remove access rules for file system objects. 
    .PARAMETER Path
        The path to the file system object to set permission for: file or directory
    .PARAMETER User
        User or group in the form DOMAIN\username.
        If no DOMAIN\ prefix is present, the local user or group is taken.
    .PARAMETER Rights
        Comma separated list of user rights: 
        AppendData, ChangePermissions, CreateDirectories, CreateFiles, Delete, DeleteSubdirectoriesAndFiles, ExecuteFile,
        FullControl, ListDirectory, Modify, Read, ReadAndExecute, ReadAttributes, ReadData, ReadExtendedAttributes, ReadPermissions, 
        Synchronize, TakeOwnership, Traverse, Write, WriteAttributes, WriteData, WriteExtendedAttributes
    .PARAMETER Access
        Access type: Allow or Deny
    .PARAMETER Action
        Type of action to do on file system object regarding access rule:
          Set         - Adds or overwrites specified ACL rules.
          Remove      - Removes specified 'Deny' or 'Allow' ACL rules.
          RemoveAll   - Removes all ACL rules for the specified user and specified access type. Rights parameter is ignored.
    .PARAMETER Inheritance
        ContainerInherit, ObjectInherit, None
        Default for files: None
        Default for dirs: ContainerInherit,ObjectInherit
    .PARAMETER Propagation
        InheritOnly, NoPropagateInherit, None
    .PARAMETER Protected
        True to protect the access rules from inheritance; false to allow inheritance.
    .PARAMETER PreserveInheritance
        True to preserve inherited access rules; false to remove inherited access rules. 
        This parameter is ignored if Protected is false.
    .EXAMPLE 
        set_fs_permission "c:\inetpub\wwwroot" "DOMAIN\user" "Read, Write"
        Allow read/write access on folder.
    .EXAMPLE 
        set_fs_permission "c:\inetpub\wwwroot" "DOMAIN\user" "Read, Write" -Access Deny
        Deny read/write acess rules on folder.
    .EXAMPLE 
        set_fs_permission "c:\inetpub\wwwroot" "DOMAIN\user" "Read" -Access Deny -Action Remove
        Remove only Deny Read rule
    .EXAMPLE 
        set_fs_permission "c:\inetpub\wwwroot" "DOMAIN\user" -Access Deny -Action RemoveAll
        Remove all Deny rules for the user
    .NOTES
        Author: Miodrag Milic
#>

function Set-FSPermissions {
  param(
    [string]$Path,
    [string]$User,
    [string]$Rights	= 'Read, ListDirectory',
    [ValidateSet('Allow', 'Deny')]
    [string]$Access	= 'Allow',
    [ValidateSet('Set', 'Remove', 'RemoveAll')]
    [string]$Action	= 'Set',	
    [string]$Inheritance = '',
    [string]$Propagation = 'None',
    [Switch]$Protected = $False,								
    [Switch]$PreserveInheritance = $False
  )
 
  function Get-Validate
  {
    param
    (
      [string]$Value,
      [String[]]$Set
    )

    $err = @()
    $Value.TrimStart() -split ',\s*' | % { if ($Set -notcontains $_) { $err += $_ }}
    if ($err.Length -gt 0) {
      'Invalid keywords: ' + ($err -join ', ')
      exit 1
    }
  }
 
  Get-Validate $Rights		('AppendData','ChangePermissions','CreateDirectories','CreateFiles','Delete','DeleteSubdirectoriesAndFiles','ExecuteFile','FullControl','ListDirectory','Modify','Read','ReadAndExecute','ReadAttributes','ReadData','ReadExtendedAttributes','ReadPermissions','Synchronize','TakeOwnership','Traverse','Write','WriteAttributes','WriteData','WriteExtendedAttributes')
  Get-Validate $Inheritance	('ContainerInherit', 'ObjectInherit', 'None', '')
  Get-Validate $Propagation	('InheritOnly', 'NoPropagateInherit', 'None')
 
  $fsInfo	 = Get-Item $path				  
  if (($Inheritance -eq '') -and ($fsInfo.GetType().Name -eq 'FileInfo')) { $Inheritance = 'None' } else { $Inheritance = 'ContainerInherit,ObjectInherit' }
  $fsSecurity = $fsInfo.GetAccessControl()  
 
  $fsRule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $Rights, $Inheritance, $Propagation, $Access )
  $fsSecurity.SetAccessRuleProtection($Protected, $PreserveInheritance)
 
  try {
    $method = @{'Remove' = 'RemoveAccessRule'; 'RemoveAll' = 'RemoveAccessRuleAll'; 'Set' = 'SetAccessRule' }[$Action]
    $fsSecurity.$method.Invoke($fsRule)
    $fsInfo.SetAccessControl($fsSecurity)
  }
  catch { 
    "EXCEPTION: $_.Exception"
    exit 1
  }
 
  $fsInfo.FullName
  (Get-Acl $Path).Access | Where-Object { $_.IdentityReference.Value.Contains($User) } | Format-Table -a IdentityReference,FileSystemRights,AccessControlType
  exit 0
}
 
 
# http://stackoverflow.com/a/6646551/82660
#  Unfortunately Get-Acl is missing some features. 
#  It always reads the full security descriptor even if you just want to modify the DACL. 
#  Thats why Set-ACL also wants to write the owner even if you have not changed it. 
#  Using the GetAccessControl method allows you to specify what part of the security descriptor you want to read.
#
#  Greska: Set-Acl : The security identifier is not allowed to be the owner of this object
 
# http://msdn.microsoft.com/en-us/library/system.io.file.setaccesscontrol.aspx
#  The ACL specified for the fileSecurity parameter replaces the existing ACL for the file. 
#  To add permissions for a new user, use the GetAccessControl method to obtain the existing ACL, modify it,
#  and then use SetAccessControl to apply it back to the file.
 
#$acl = Get-Acl $Path 
#http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.directorysecurity.aspx -> Examples
 
#Links:
# http://msdn.microsoft.com/en-us/library/system.io.file.setaccesscontrol.aspx
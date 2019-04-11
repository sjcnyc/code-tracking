#requires -Modules ActiveDirectory
#Requires -Version 2 
<# 
    .SYNOPSIS 
    Create Home folders and assign permissions
  
    .DESCRIPTION 
    Create Home folders and assign permissions
  
    .NOTES 
    File Name  : Add-HomeFolder
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 2/24/2015
  
    .LINK 
    This script posted to: http://www.github/sjcnyc
    http://msdn.microsoft.com/en-us/library/ms147785(v=vs.90).aspx
  
    .EXAMPLE
    Add-HomeFolder -path \\setver\home -userlist c:\userlist.txt -logpath c:\
  
    .EXAMPLE
    Add-HomeFolder -path \\setver\home -userlist c:\userlist.txt -logpath c:\ -FullControlMember "file admin", "fileadmins"
#>

function Add-HomeFolder
{
  param
  (
    [String]$Path,
    [String]$UserList,
    [String[]]$FullControlMember,
    [string]$logpath
  )
  
  $Users = @()
  $Results = @()
  Import-Module -Name ActiveDirectory

  if (-not (Test-Path $Path))
  {
    Write-Error -Message "Cannot find path '$Path' because it does not exist."
    return
  }
  if (-not (Test-Path $UserList))
  {
    Write-Error -Message "Cannot find  '$UserList' because it does not exist."
    return
  }
  else
  {$Users = Get-Content $UserList}
  #Check whether the input AD member is correct
  if ($FullControlMember)
  {
    $FullControlMember | ForEach-Object -Process {
      if (-not(Get-ADObject -Filter 'name -Like $_'))

      {
        $FullControlMember = $FullControlMember -notmatch $_
        Write-Error -Message "Cannot find an object with name:'$_'"
      }
    }
  }
  $FullControlMember += 'NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators'
  
  foreach($User in $Users)
  {
    $HomeFolderACL = Get-Acl $Path
    $HomeFolderACL.SetAccessRuleProtection($true,$false)
    $Result = New-Object -TypeName PSObject
    $Result | Add-Member -MemberType NoteProperty -Name 'Name' -Value $User
    if (Get-ADUser -Filter 'SAMAccountName -Like $User')
    {
      $null = New-Item -ItemType directory -Path "$Path\$User"
      #set acl to folder
      $FCList = $FullControlMember+$User
      $FCList | ForEach-Object -Process {
        $ACL = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList ($_, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
        $HomeFolderACL.AddAccessRule($ACL)
      }
      Set-Acl -Path "$Path\$User" -AclObject $HomeFolderACL
      $Result | Add-Member -MemberType NoteProperty -Name 'IsCreated' -Value 'Yes'
      $Result | Add-Member -MemberType NoteProperty -Name 'Remark' -Value 'N/A'
    }
    else
    {
      $Result | Add-Member -MemberType NoteProperty -Name 'IsCreated' -Value 'No'
      $Result | Add-Member -MemberType NoteProperty -Name 'Remark' -Value "Cannot fine an object with name:'$User'"
    }
    $Results += $Result
  }
  #Generate a report
  $Results | Export-Csv -NoTypeInformation -Path "$logpath\Report.csv"
  if ($?) 
  {Write-Host -Object "Please check the report for detail: '$logpath\Report.csv'"}
}

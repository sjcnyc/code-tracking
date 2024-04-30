#Requires -Version 3.0 
#Requires -PSSnapin Quest.ActiveRoles.ADManagement
<# 
    .SYNOPSIS
      Create user Home folder with NTFS permissions and add to AD profile

    .DESCRIPTION
      Create user Home folder with NTFS permissions and add to AD profile 
    .NOTES 
        File Name  : New-HomeFolders.ps1
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 11/4/2015

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE
#>

function Write-Log
{
  [CmdletBinding()]
  
  Param ([Parameter(Mandatory=$true)][string]$LogPath, 
         [Parameter(Mandatory=$true)][string]$LineValue
  )
  
  Process{
    Add-Content -Path $LogPath -Value $LineValue  
    #Write to screen for debug mode
    Write-Verbose $LineValue
  }
} 

if ((Get-PSSnapin |
 Where-Object -FilterScript {$_.Name -match 'Quest.ActiveRoles.ADManagement'}) -eq $null)
{Add-PSSnapin -Name Quest.ActiveRoles.ADManagement}

$NetPath = '\\storage\home$'
#$users = Get-Content -Path '.\users.txt'
$users = 'sc_testuser'
$logPath = 'c:\temp\newLog.txt'
$dletter = 'H:'

$users | ForEach-Object -Process {

  Write-Log -LogPath $logPath -LineValue "Processing User: $($_)" -Verbose
  $qaduser = Get-QADUser -Identity $_ 

  $userhomepath = $NetPath + '\' + $_

  if(-not(Test-Path $userhomepath))
  {
    New-Item -Path $userhomepath -ItemType Directory | Out-Null
    Write-Log -LogPath $logPath -LineValue "Created: $($userhomepath)" -Verbose
    $acl = Get-Acl $userhomepath

    $inheritanceFlags = ([Security.AccessControl.InheritanceFlags]::ContainerInherit -bor `
    [Security.AccessControl.InheritanceFlags]::ObjectInherit)
    $propagationFlags = [Security.AccessControl.PropagationFlags]::None

    $permissions = $_, 'Modify', $inheritanceFlags, $propagationFlags, 'Allow'
    $access = New-Object -TypeName system.security.accesscontrol.filesystemaccessrule -ArgumentList ($permissions)
    $acl.SetAccessRule($access)
    $acl | Set-Acl $userhomepath 

    $homedir = $qaduser.HomeDirectory
    if ($homedir -eq $null)
    {
      Get-QADUser -Identity $_ | Set-QADUser -ObjectAttributes @{
        HomeDirectory = $userhomepath
      } | Out-Null
      Get-QADUser -Identity $_ | Set-QADUser -ObjectAttributes @{
        HomeDrive = $dletter
      } | Out-Null
      
      $usr = Get-QADUser -Identity $_ 

      Write-Log -LogPath $logPath -LineValue "Added Homedrive: $($usr.HomeDrive) and Home Directory: $($usr.HomeDirectory)" -Verbose
    }
    else {Write-Log -LogPath $logPath -LineValue "Entry: $($usr.HomeDirectory) already exists in AD for $($_)" -Verbose }
  }
  else
  {
    Write-Log -LogPath $logPath -LineValue "Folder: $($userhomepath) already exists" -Verbose
    $homedir = $qaduser.HomeDirectory
    if ($qaduser.HomeDirectory -eq $null)
    {
      Get-QADUser -Identity $_ | Set-QADUser -ObjectAttributes @{
        HomeDirectory = $userhomepath
      } | Out-Null
      Get-QADUser -Identity $_ | Set-QADUser -ObjectAttributes @{
        HomeDrive = $dletter
      } | Out-Null
      $usr = Get-QADUser -Identity $_

      Write-Log -LogPath $logPath -LineValue "Added Homedrive: $($usr.HomeDrive) and Home directory: $($usr.HomeDirectory)" -Verbose
    }
    else { Write-Log -LogPath $logPath -LineValue "Entry: $($usr.HomeDirectory) already exists in AD for $($_)" -Verbose
    }
  }
  Write-Log -LogPath $logPath -LineValue ' ' -Verbose
}
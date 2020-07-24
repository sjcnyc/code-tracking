function Get-GroupMembersWithAttributes {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True)]
    [string]$GroupName,

    [Parameter(Mandatory = $True)]
    [string]$SearchOU,
    
    [Parameter(Mandatory = $True)]
    [string]$ParentTree,

    [string]$OutputProperties = 'Name,EmailAddress',

    [string]$OutputFilePath = [Environment]::GetFolderPath("Desktop"),

    [string]$OutputFileName = $GroupName + '_GroupMembership.csv'
  )
  #Requires -Version 2.0

  Import-Module ActiveDirectory
  If ($null -eq (Get-Module ActiveDirectory -ErrorAction SilentlyContinue)) {
    Write-Host "This script requires the Powershell Module: 'ActiveDirectory'. Please make sure you've got the correct tools installed." -ForegroundColor Red
    Exit   
  }
  Else {
    $groupDN = "CN=$GroupName,OU=$SearchOU,$ParentTree"

    ForEach ($member in (Get-ADGroupMember $groupDN)) {
      Get-ADUser -Filter {Name -eq $member.Name} -Properties * |Select-Object $OutputProperties.Split(",") |Export-Csv -Path $OutputFilePath'\'$OutputFileName -NoTypeInformation -Append
    }
  }
}



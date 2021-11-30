Function Get-PIMRoleAssignment {
  <#
.SYNOPSIS
    This will check if a user is added to PIM or standing access.
    For updated help and examples refer to -Online version.
 
.NOTES
    Name: Get-PIMRoleAssignment
    Author: theSysadminChannel
    Version: 1.0
    DateCreated: 2021-May-15
 
.EXAMPLE
    Get-PIMRoleAssignment -UserPrincipalName blightyear@thesysadminchannel.com
 
.EXAMPLE
    Get-PIMRoleAssignment -RoleName 'Global Administrator'
 
.LINK
    https://thesysadminchannel.com/get-pim-role-assignment-status-for-azure-ad-using-powershell -
#>
 
  [CmdletBinding()]
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      ParameterSetName = 'User',
      Position = 0
    )]
    [string[]]  $UserPrincipalName,
 
 
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      ParameterSetName = 'Role',
      Position = 1
    )]
    [Alias('DisplayName')]
    [ValidateSet(
      'Application Administrator',
      'Application Developer',
      'Attack Simulation Administrator',
      'Authentication Administrator',
      'Azure Information Protection Administrator',
      'Billing Administrator',
      'Cloud Device Administrator',
      'Compliance Administrator',
      'Conditional Access Administrator',
      'Device Managers',
      'Directory Readers',
      'Directory Writers',
      'Exchange Administrator',
      'Exchange Recipient Administrator',
      'Global Administrator',
      'Global Reader',
      'Helpdesk Administrator',
      'Intune Administrator',
      'License Administrator',
      'Message Center Privacy Reader',
      'Message Center Reader',
      'Power BI Administrator',
      'Power Platform Administrator',
      'Privileged Authentication Administrator',
      'Privileged Role Administrator',
      'Reports Reader',
      'Search Administrator',
      'Security Administrator',
      'Security Reader',
      'Service Support Administrator',
      'SharePoint Administrator',
      'Skype for Business Administrator',
      'Teams Administrator',
      'Teams Communications Administrator',
      'Teams Communications Support Engineer',
      'Teams Communications Support Specialist',
      'User Administrator'
    )]
    [string]    $RoleName,
 
 
    [string]    $TenantId
  )
 
  BEGIN {
    $SessionInfo = Get-AzureADCurrentSessionInfo -ErrorAction Stop
    if (-not ($PSBoundParameters.ContainsKey('TenantId'))) {
      $TenantId = $SessionInfo.TenantId
    }
 
    $AdminRoles = Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $TenantId -ErrorAction Stop | Select-Object Id, DisplayName
    $RoleId = @{}
    $AdminRoles | ForEach-Object { $RoleId.Add($_.DisplayName, $_.Id) }
  }
 
  PROCESS {
    if ($PSBoundParameters.ContainsKey('UserPrincipalName')) {
      foreach ($User in $UserPrincipalName) {
        try {
          $AzureUser = Get-AzureADUser -ObjectId $User -ErrorAction Stop | Select-Object DisplayName, UserPrincipalName, ObjectId
          $UserRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId aadRoles -ResourceId $TenantId -Filter "subjectId eq '$($AzureUser.ObjectId)'"
 
          if ($UserRoles) {
            foreach ($Role in $UserRoles) {
              $RoleObject = $AdminRoles | Where-Object { $Role.RoleDefinitionId -eq $_.id }
 
              [PSCustomObject]@{
                UserPrincipalName = $AzureUser.UserPrincipalName
                AzureADRole       = $RoleObject.DisplayName
                PIMAssignment     = $Role.AssignmentState
                MemberType        = $Role.MemberType
              }
            }
          }
        }
        catch {
          Write-Error $_.Exception.Message
        }
      }
    }
 
    if ($PSBoundParameters.ContainsKey('RoleName')) {
      try {
        $RoleMembers = @()
        $RoleMembers += Get-AzureADMSPrivilegedRoleAssignment -ProviderId aadRoles -ResourceId $TenantId -Filter "RoleDefinitionId eq '$($RoleId[$RoleName])'" -ErrorAction Stop | Select-Object RoleDefinitionId, SubjectId, StartDateTime, EndDateTime, AssignmentState, MemberType
 
        if ($RoleMembers) {
          $RoleMemberList = $RoleMembers.SubjectId | Select-Object -Unique
          $AzureUserList = foreach ($Member in $RoleMemberList) {
            try {
              Get-AzureADUser -ObjectId $Member | Select-Object ObjectId, UserPrincipalName
            }
            catch {
              Get-AzureADGroup -ObjectId $Member | Select-Object ObjectId, @{Name = 'UserPrincipalName'; Expression = { "$($_.DisplayName) (Group)" } }
              $GroupMemberList = Get-AzureADGroupMember -ObjectId $Member | Select-Object ObjectId, UserPrincipalName
              foreach ($GroupMember in $GroupMemberList) {
                $RoleMembers += Get-AzureADMSPrivilegedRoleAssignment -ProviderId aadRoles -ResourceId $TenantId -Filter "RoleDefinitionId eq '$($RoleId[$RoleName])' and SubjectId eq '$($GroupMember.objectId)'" -ErrorAction Stop | Select-Object RoleDefinitionId, SubjectId, StartDateTime, EndDateTime, AssignmentState, MemberType
              }
              Write-Output $GroupMemberList
            }
          }
 
          $AzureUserList = $AzureUserList | Select-Object ObjectId, UserPrincipalName -Unique
          $AzureUserHash = @{}
          $AzureUserList | ForEach-Object { $AzureUserHash.Add($_.ObjectId, $_.UserPrincipalName) }
 
          foreach ($Role in $RoleMembers) {
            [PSCustomObject]@{
              UserPrincipalName = $AzureUserHash[$Role.SubjectId]
              AzureADRole       = $RoleName
              PIMAssignment     = $Role.AssignmentState
              MemberType        = $Role.MemberType
            }
          }
        }
      }
      catch {
        Write-Error $_.Exception.Message
      }
    }
  }

  END {}
 
}
function Add-PIMRoleAssignment {
  <#
.Synopsis
    This add a user to a PIM Role in Azure AD.
    For updated help and examples refer to -Online version.
 
.NOTES
    Name: Add-PIMRoleAssignment
#>
 
  [CmdletBinding()]
  param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0
    )]
    [string[]]
    $UserPrincipalName,
 
 
    [Parameter(
      Mandatory = $true,
      Position = 1
    )]
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
    [string]
    $RoleName,
 
    [Parameter(
      Mandatory = $false,
      Position = 2
    )]
    [string]
    $TenantId,
 
    [Parameter(
      Mandatory = $false,
      Position = 3
    )]
    [int]
    $DurationInMonths = 48,
 
    [Parameter(
      Mandatory = $false,
      Position = 4
    )]
    [Alias('Justification')]
    [string]
    $TicketNumber
 
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
    $Schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
    $Schedule.Type = 'Once'
    $Schedule.StartDateTime = (Get-Date)
    $Schedule.EndDateTime = (Get-Date).AddMonths($DurationInMonths)
 
    foreach ($User in $UserPrincipalName) {
      try {
        $AzureADUser = Get-AzureADUser -ObjectId $User -ErrorAction Stop | Select-Object UserPrincipalName, ObjectId
        Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId Aadroles -Schedule $Schedule -ResourceId $TenantId -RoleDefinitionId $RoleId[$RoleName] `
          -SubjectId $AzureADUser.ObjectId -AssignmentState Eligible -Type AdminAdd -Reason $TicketNumber -ErrorAction Stop | Out-Null
 
        [PSCustomObject]@{
          UserPrincipalName = $AzureADUser.UserPrincipalName
          RoleName          = $RoleName
          DurationInMonths  = $DurationInMonths
          Justification     = $TicketNumber
        }
      }
      catch {
        Write-Error $_.Exception.Message
      }
    }
  }
  END {}
}
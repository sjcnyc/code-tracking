Connect-AzureAD

# find your guids once and fill in the values
$values = [PSCustomObject]@{
  Reason           = 'Support'
  Hours            = 2
  ResourceId       = 'COMPANY-ID-HERE'
  SubjectId        = 'MY-ID-HERE'
  RoleDefinitionId = 'f28a1f50-f6e7-4571-818b-6a12f2af6b6c'
}

$schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$schedule.Type = 'Once'
$now = (Get-Date).ToUniversalTime()
$schedule.StartDateTime = $now.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
$schedule.EndDateTime = $now.AddHours($values.Hours).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')

$openAzureADMSPrivilegedRoleAssignmentRequestSplat = @{
  ProviderId       = 'aadRoles'
  ResourceId       = $values.ResourceId
  RoleDefinitionId = $values.RoleDefinitionId
  SubjectId        = $values.SubjectId
  Type             = 'UserAdd'
  AssignmentState  = 'Active'
  Schedule         = $schedule
  Reason           = $values.Reason
}

Open-AzureADMSPrivilegedRoleAssignmentRequest @openAzureADMSPrivilegedRoleAssignmentRequestSplat
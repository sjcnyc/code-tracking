<#NOTE:
This script requires the AzureADPreview Powershell module. Install-Module AzureADPreview -Scope CurrentUser
This script requires the Az.Accounts Powershell module. Install-Module Az.Accounts -Scope CurrentUser
This script requires the Microsoft.Graph powershell module to be installed
#>

$Script:TenantId = 'Your-Tenant-Id-Here'

function Get-AzurePIMRoles {
  Param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $UserUPN
  )

  $context = Get-AzContext
  if ([string]::IsNullOrEmpty($UserUPN)) { 
    $UserUPN = Read-Host 'UserPrincipalName'
  }
  $AzureUser = Get-AzureADUser -SearchString $UserUPN | Select-Object * # Get the info from logged in user
  if ($null -ne $AzureUser) {
    $AzureUserId = $AzureUser.ObjectId
    #Get roles
    $AssignedRoles =
    Get-AzureADMSPrivilegedRoleAssignment -ProviderId 'aadroles' -ResourceId $context.Tenant.Id -Filter "subjectId eq '$AzureUserId'" | Select-Object *
    return $AssignedRoles
  }
  else {
    Write-Error "User '$UserUPN' could not be found. Aborting"
  }
}

function Enable-AllPimRoles {
  $context = Get-AzContext
  $schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
  $schedule.Type = 'Once'
  $schedule.StartDateTime = (Get-Date).ToUniversalTime().AddSeconds(30).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
  $schedule.endDateTime = (Get-Date).ToUniversalTime().AddHours(10).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
  if ($null -eq $context) {
    $context = Start-AzureLogon
  }
  else {
    Connect-AzureAD -AccountId $context.Account.Id
  }
  $Roles = Get-AzurePIMRoles -UserUpn $context.Account.Id
  $ActivationReason = Read-Host 'Activation Reason(required)'
  while ([system.string]::IsNullOrEmpty($ActivationReason)) {
    Write-Host 'Activation Reason is required!' -ForegroundColor Yellow
    $ActivationReason = 'enable role'
  }
  $allRoles = Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $context.Tenant.Id
  $PercentPerRole = 101 / $Roles.Count
  $complete = 0
  foreach ($role in $Roles) {
    $CurrentRole = $allRoles | Where-Object { $_.Id -eq $role.RoleDefinitionId }
    Write-Host "Role: $($CurrentRole.DisplayName)"
    if ($role.AssignmentState -ne 'Active') {
      Write-Progress -Activity "Activating $($CurrentRole.DisplayName)" -Status 'Progress->' -PercentComplete $complete -CurrentOperation '$' -Id '1'
      Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -ResourceId $role.ResourceId -RoleDefinitionId $role.RoleDefinitionId -SubjectId $role.SubjectId -Type 'UserAdd' -AssignmentState 'Active' -schedule $schedule -reason $ActivationReason
    }
    $complete += $PercentPerRole
  }
  Start-Sleep -Seconds 1
  Write-Progress -Id '1' -Activity 'Completed Role Activation' -Status 'Complete'
}
function Enable-PimRole {
  $context = Get-AzContext
  $schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
  $schedule.Type = 'Once'
  $schedule.StartDateTime = (Get-Date).ToUniversalTime().AddSeconds(30).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
  $schedule.endDateTime = (Get-Date).ToUniversalTime().AddHours(10).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
  if ($null -eq $context) {
    $context = Start-AzureLogon
  }
  else {
    Connect-AzureAD -AccountId $context.Account.Id
  }
  $Roles = Get-AzurePIMRoles -UserUpn $context.Account.Id
  $allRoles = Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $context.Tenant.Id
    
  do {
    for ($i = 0; $i -lt $Roles.Count; $i++) {
      $role = $allRoles | Where-Object { $_.Id -eq $Roles[$i].RoleDefinitionId }
      if ($Roles[$i].AssignmentState -eq 'Active') {
        Write-Host "$($i+1): $($role.DisplayName) (Already Activated)" -ForegroundColor Green
      }
      else {
        Write-Host "$($i+1): $($role.DisplayName)"
      }
    }
    $RoleChoice = Read-Host 'Activate Role'
  } until ($RoleChoice -gt 0 -or $RoleChoice -lt $Roles.Count + 1)
  $ActivationReason = Read-Host 'Activation Reason(required)'
  while ([system.string]::IsNullOrEmpty($ActivationReason)) {
    Write-Host 'Activation reason is required!' -ForegroundColor Yellow
    $ActivationReason = Read-Host 'Activation Reason(required)'
  }
  $CurrentRole = $allRoles | Where-Object { $_.Id -eq $Roles[$RoleChoice - 1].RoleDefinitionId }
  Write-Host "Activating Role: $($CurrentRole.DisplayName)"
  if ($role.AssignmentState -ne 'Active') {
    Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -ResourceId $Roles[$RoleChoice - 1].ResourceId -RoleDefinitionId $Roles[$RoleChoice - 1].RoleDefinitionId -SubjectId $Roles[$RoleChoice - 1].SubjectId -Type 'UserAdd' -AssignmentState 'Active' -schedule $schedule -reason $ActivationReason
  }
  Start-Sleep -Seconds 1
  Write-Progress -Id '1' -Activity 'Completed Role Activation' -Status 'Complete'
}

function Start-AzureLogon {
  Login-AzAccount -TenantId $TenantId -Environment AzureCloud
  $azContext = Get-AzContext
  Connect-AzureAD -TenantId $TenantId -AccountId $azContext.Account.Id
  return $azContext
}

Write-Host 'Starting...' -ForegroundColor Green

Import-Module azureadpreview
Write-Host 'imported modules' -ForegroundColor Green
$ActivationHours = 10 #Depending on your Tenant Settings this has to be changed to your max activation hours
$schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$schedule.Type = 'Once'
$schedule.StartDateTime = (Get-Date).ToUniversalTime().AddSeconds(60).ToString('yyyy-MM-ddTHH:mm:ss.fffZ') #Start Time is set to 60 seconds from the point 
$schedule.endDateTime = (Get-Date).ToUniversalTime().AddHours($ActivationHours).ToString('yyyy-MM-ddTHH:mm:ss.fffZ') #Sets end time

do {
  Write-Host "1. Activate All Roles`n2. Active Single Roles"
  $Choice = Read-Host 'Enter your choice (1-2)'
} until ($Choice -eq 1 -or $Choice -eq 2)

switch ($choice) {
  '1' { 
    Enable-AllPimRoles
  }
  '2' {
    Enable-PimRole
  }
  Default {}
}
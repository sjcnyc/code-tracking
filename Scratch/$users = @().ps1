$users = @()
$logs = Get-AzureADAuditDirectoryLogs -All $true -Filter "activityDateTime gt 2021-04-16 and Category eq 'UserManagement' and OperationType eq 'Update' and ActivityDisplayName eq 'Update user'"
foreach ($log in $logs) {

  if ($log.TargetResources.ModifiedProperties.NewValue[1].Trim(""",""") -eq 'Mobile' -or $log.TargetResources.ModifiedProperties.NewValue[1].Trim(""",""") -eq 'TelephoneNumber') {
    $obj = [PSCustomObject]@{
      UserPrincipalName = $log.TargetResources.UserPrincipalName
      Phone             = $log.TargetResources.ModifiedProperties.NewValue[0].Trim("["",""]")
    }
    $users += $obj
  }
}
$users | Export-Csv -Path C:\temp\phone.csv -NoTypeInformation


$data = Get-AzureADAuditDirectoryLogs -Filter "initiatedBy/user/userPrincipalName eq 'Luke.Gervase.Admin@SonyMusicEntertainment.onmicrosoft.com'"

$data | Export-Csv d:\temp\test_luke.csv -NoTypeInformation
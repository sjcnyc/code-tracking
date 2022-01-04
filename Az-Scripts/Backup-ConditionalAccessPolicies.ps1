function Backup-ConditionalAccessPolicies {
  param(
    [parameter()]
    [String]$BackupPath
  )
  # Connect to Azure AD
  Connect-AzureAD

  $AllPolicies = Get-AzureADMSConditionalAccessPolicy

  foreach ($Policy in $AllPolicies) {
    Write-Output "Backing up $($Policy.DisplayName)"
    $PolicyJSON = $Policy | ConvertTo-Json -Depth 6
    $PolicyJSON | Out-File "$BackupPath\$($Policy.Id).json"
  }
}
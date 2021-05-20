Import-Module ExchangeOnline

Connect-EXOService -UserPrincipalName "admSConnea-azr@SonyMusicEntertainment.onmicrosoft.com" -BypassMailboxAnchoring:$true

$UserPrincipalName = "brian.lynch@sonymusic.com"

  $StartDate = (get-date).AddDays(-30).ToString("MM/dd/yyyy")
  $EndDate = (get-date).AddDays(1).ToString("MM/dd/yyyy")

function Get-FileSharing {
  Write-ProgressHelper -Activity 'Checking file sharing'
  $operations = @('AnonymousLinkCreated', 'SecureLinkCreated', 'AddedToSecureLink')
  $auditLinks = Search-UnifiedAuditLog -UserIds $UserPrincipalName -StartDate $StartDate -EndDate $EndDate -Operations $operations
  if ($auditLinks) {
    foreach ($link in $auditLinks) {
      $checkFileSharingOutput = "" | Select-Object -Property Check, User, Operation, FilePath, Recipient, Created
      $checkFileSharingOutput.Check = 'FileSharing'
      $checkFileSharingOutput.User = $UserPrincipalName
      $checkFileSharingOutput.Operation = $link.Operation
      $checkFileSharingOutput.FilePath = $link.ObjectId
      if ($link.Operation -eq 'AddedToSecureLink') {
        $checkFileSharingOutput.Recipient = $link.TargetUserOrGroupName
      }
      $checkFileSharingOutput.Created = $link.CreationTime #CreationTime is returned in local time
      $checkFileSharingOutput
    }
		}
  else {
    if ($ShowNonMatches) { Write-Host 'FileSharing: No files were shared within the search window.' }
  }
}

Get-FileSharing
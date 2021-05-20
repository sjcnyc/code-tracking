Function Move-ADUserToNewGroup {
  [CmdletBinding(SupportsShouldProcess=$true)]
  Param(
    $SourceGroup,
    $TargetGroup='USA-GBL Outlook'
  )
  
  Get-QADGroup $SourceGroup | Get-QADGroupMember | Select-Object samaccountname |    
  ForEach-Object {
    Write-host "- Removing $($_.samaccountname) from: $($sourceGroup)" -For Red
    Remove-QADGroupMember -I $sourceGroup -Member $_.samaccountname | Out-Null
    Write-host "+ Adding $($_.samaccountname) to: $($targetgroup)" -For Green
    Add-QADGroupMember -I $targetgroup -Member $_.samaccountname | out-null
  } 
}
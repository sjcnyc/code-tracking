#Connect-AzureAD
# Import-Module AzureAD
function Remove-CloudGroups {
  [CmdletBinding(SupportsShouldProcess)]
  param (
    [Parameter(Mandatory)][string]
    $UserPrincipalName
  )
  
  $UserId = (Get-AzureADUser -ObjectId $UserPrincipalName).ObjectId

  $Groups =
  (Get-AzureADUserMembership -ObjectId $UserId).Where{ $_.ObjectType -eq 'Group' }

  foreach ($Group in $Groups) {

    $g = (Get-AzureADGroup -ObjectId $Group.ObjectId).Where{ $null -eq $_.DirSyncEnabled }

    Remove-AzureADGroupMember -ObjectId $g.ObjectId -MemberId $UserId
  }
}

Remove-CloudGroups -UserPrincipalName 'sean.connealy.peak@sonymusic.com' -WhatIf


Remove-AzureADGroupMember -ObjectId 9ad81868-d5eb-455d-a1c0-d8047999f4d7 -MemberId (Get-AzureADGroupMember -ObjectId 9ad81868-d5eb-455d-a1c0-d8047999f4d7 -All $true | Where-Object { $\_.dirsyncenabled -EQ $true } | Select-Object -ExpandProperty objectid)
function Get-IsAzGroupmember {
  param (
    [string]
    $GroupObjectId,
    [string]
    $UserName
  )

  $g = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
  $g.GroupIds = $GroupObjectId
  $User = (Get-AzureADUser -Filter "userprincipalname eq '$($Username)'").ObjectId
  $InGroup = Select-AzureADGroupIdsUserIsMemberOf -ObjectId $User -GroupIdsForMembershipCheck $g

  if ($InGroup -eq $GroupObjectId) {
    return $true
  }
  else {
    return $false
  }
}

#Connect-MsolService
#Connect-AzureAD

$MFAUsers = Get-Msoluser -all

$NoMfaGroup = "af67af47-8f94-45c7-a806-2b0b9f3c760e" #"AZ_OnPremOnly_NoMFA_Test"

$NonMfaUsers = $MFAUsers |Where-Object {$_.StrongAuthenticationMethods.Count -eq 0  } # -and $_.ImmutableID -eq $null

$UsersAddedToGroup = 0

foreach ($User in $NonMfaUsers) {
  try {

    $Group = Get-IsAzGroupmember -GroupObjectId $NoMfaGroup -UserName $User.UserPrincipalName

    if ($Group -ne $true) {
      # Add-MsolGroupMember -GroupObjectId $NoMfaGroup -GroupMemberObjectId $user.ObjectId -ErrorAction Stop
      $UsersAddedToGroup ++
      Write-Output "Adding $($User.UserPrincipalName) to group.."
    }
  }
  catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
      $_.Exception.Message  # Commented because output not required
  }
  catch {
     $_.Exception.Message  # Commented because output not required
  }
}

$NoMfaGroupUserCount = (Get-MsolGroupMember -GroupObjectId $NoMfaGroup -All).Count

Write-Output "Syncronized Users Added: $($UsersAddedToGroup)"
Write-Output "Syncronyzed Users Total: $($NoMfaGroupUserCount)"

(Get-AzureADGroupMembers -ObjectId $NoMfaGroup).Count
#Connect-MsolService
#Connect-AzureAD

$MFAUsers = Get-Msoluser -all

$NoMfaGroup = "af67af47-8f94-45c7-a806-2b0b9f3c760e" #"AZ_OnPremOnly_NoMFA_Test"

$NonMfaUsers = $MFAUsers |Where-Object {$_.StrongAuthenticationMethods.Count -eq 0  } # -and $_.ImmutableID -eq $null

$UsersAddedToGroup = 0

foreach ($User in $NonMfaUsers) {
  try {

    $InGroup = (Get-AzureADUser -SearchString $User.UserPrincipalName | Get-AzureADUserMembership).Displayname -eq "AZ_OnPremOnly_NoMFA_TEST"

    if (!($InGroup)) {
      #Add-MsolGroupMember -GroupObjectId $NoMfaGroup -GroupMemberObjectId $user.ObjectId -ErrorAction Stop
      $UsersAddedToGroup ++
      Write-Output "Adding $($User.UserPrincipalName) to group.."
    }
    else {

    }
  }
  catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
    #  $_.Exception.Message  # Commented because output not required
  }
  catch {
    # $_.Exception.Message  # Commented because output not required
  }
}

$NoMfaGroupUserCount = (Get-MsolGroupMember -GroupObjectId $NoMfaGroup -All).Count

Write-Output "Syncronized Users Added: $($UsersAddedToGroup)"
Write-Output "Syncronyzed Users Total: $($NoMfaGroupUserCount)"
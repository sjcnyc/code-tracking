#Connect-MsolService

$MFAUsers = Get-Msoluser -all

$NoMfaGroup = "af67af47-8f94-45c7-a806-2b0b9f3c760e" #"AZ_OnPremOnly_NoMFA_Test"

$NonMfaUsers = $MFAUsers |Where-Object {$_.StrongAuthenticationMethods.Count -eq 0  } # -and $_.ImmutableID -eq $null

$UsersAddedToGroup = 0

foreach ($user in $NonMfaUsers) {
  try {

    Add-MsolGroupMember -GroupObjectId $NoMfaGroup -GroupMemberObjectId $user.ObjectId -ErrorAction Stop
    $UsersAddedToGroup ++
  }
  catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
  #  $_.Exception.Message
  }
  catch {
   # $_.Exception.Message
  }
}

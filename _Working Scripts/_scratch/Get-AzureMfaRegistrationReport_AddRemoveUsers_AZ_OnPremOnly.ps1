using namespace System.Collections.Generic

$AutomationPSCredentialName = "t2_cloud_cred"
$Credential = Get-AutomationPSCredential -Name $AutomationPSCredentialName -ErrorAction Stop

Connect-MsolService -Credential $Credential -ErrorAction SilentlyContinue
Connect-AzureAD -Credential $Credential -ErrorAction SilentlyContinue

$PSList            = [List[psobject]]::new()
$PListUsersAdded   = [List[psobject]]::new()
$PListUsersRemoved = [List[psobject]]::new()

$AZ_GroupName      = "AZ_Auth_OnPremOnly"
$Date              = (Get-Date -f yyyy-MM-dd)
$CSVFile           = "C:\support\MFAUserReport_$($Date).csv"
$UserAddedCsv      = "C:\support\UsersAdded_$($AZ_GroupName)_$($Date).csv"
$UserRemovedCsv    = "C:\support\UsersRemoved_$($AZ_GroupName)_$($Date).csv"
$ScriptStartedTime = (Get-Date -Format G)
$g                 = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck

$CSVFiles = @($CSVFile)

$Style1 =
'<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
  </style>'

$UserCounter           = 0
$UsersAddedToGroup     = 0
$UsersRemovedFromGroup = 0
$MethodTypeCount       = 0
$MFAUsers              = Get-Msoluser -All
$NoMfaGroup            = "af67af47-8f94-45c7-a806-2b0b9f3c760e" # AZ_Auth_OnPremOnly

foreach ($User in $MfaUsers) {

  $UserCounter ++

  $StrongAuthenticationRequirements = $User | Select-Object -ExpandProperty StrongAuthenticationRequirements
  $StrongAuthenticationUserDetails  = $User | Select-Object -ExpandProperty StrongAuthenticationUserDetails
  $StrongAuthenticationMethods      = $User | Select-Object -ExpandProperty StrongAuthenticationMethods

  $MethodTypeCount += ($StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $True }).count

  $PSObj = [pscustomobject]@{
    DisplayName                                = $User.DisplayName -replace "#EXT#", ""
    UserPrincipalName                          = $User.UserPrincipalName -replace "#EXT#", ""
    Country                                    = $User.Country
    City                                       = $User.City
    Office                                     = $User.Office
    Department                                 = $User.Department
    IsLicensed                                 = $User.IsLicensed
    MFAState                                   = $StrongAuthenticationRequirements.State
    RememberDevicesNotIssuedBefore             = $StrongAuthenticationRequirements.RememberDevicesNotIssuedBefore
    StrongAuthenticationUserDetailsPhoneNumber = $StrongAuthenticationUserDetails.PhoneNumber
    StrongAuthenticationUserDetailsEmail       = $StrongAuthenticationUserDetails.Email
    DefaultStrongAuthenticationMethodType      = ($StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $True }).MethodType
  }
  [void]$PSList.Add($PSObj)

  try {
    $g.GroupIds = $NoMfaGroup
    $Group = Select-AzureADGroupIdsUserIsMemberOf -ObjectId $User.ObjectId -GroupIdsForMembershipCheck $g

    if ($Group -ne $NoMfaGroup -and $User.StrongAuthenticationMethods.Count -eq 0) {
      $UsersAddedToGroup ++
      Write-Output "Adding $($User.UserPrincipalName) to group.."
      Add-MsolGroupMember -GroupObjectId $NoMfaGroup -GroupMemberObjectId $user.ObjectId -ErrorAction Continue

      $PSUserObjAdded = [PSCustomObject]@{
        'DisplayName'       = $User.DisplayName
        'UserPrincipalName' = $User.UserPrincipalName
      }
      [void]$PListUsersAdded.Add($PSUserObjAdded)
    }
    elseif ($Group -eq $NoMfaGroup -and $User.StrongAuthenticationMethods.Count -gt 0) {
      $UsersRemovedFromGroup ++
      Write-Output "Removing $($User.UserPrincipalName) from group.."
      Remove-MsolGroupMember -GroupObjectId $NoMfaGroup -GroupMemberObjectId $user.ObjectId -ErrorAction Continue

      $PSUserObjRemoved = [PSCustomObject]@{
        'DisplayName'       = $User.DisplayName
        'UserPrincipalName' = $User.UserPrincipalName
      }
      [void]$PListUsersRemoved.Add($PSUserObjRemoved)
    }
  }
  catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
    Write-Output $_.Exception.Message
  }
  catch {
    Write-Output $_.Exception.Message
  }
}

$NoMfaGroupUserCount = (Get-MsolGroupMember -GroupObjectId $NoMfaGroup -All).Count

$InfoBody = [pscustomobject]@{
  'Task'            = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'          = "Azure MFA Registration Report"
  'Mfa Users Total' = $MethodTypeCount
  'Users Total'     = $UserCounter
}

if ($UsersAddedToGroup -eq 0) { $UserAddedCount = '0' } else { $UserAddedCount = $UsersAddedToGroup }
if ($UsersRemovedFromGroup -eq 0) { $UserRemovedCount = '0' } else { $UserRemovedCount = $UsersRemovedFromGroup }

$SyncUsers = [PSCustomObject]@{
  'Cloud Group'   = $AZ_GroupName
  'Users Added'   = $UserAddedCount
  'Users Removed' = $UserRemovedCount
  'Users Total'   = $NoMfaGroupUserCount
}

$PSList | Export-Csv $CSVFile -NoTypeInformation

try {

  $HTML = New-HTMLHead -title "Azure MFA Registration Report" -style $Style1
  $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
  $HTML += "<h4>&nbsp;</h4>"
  $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $SyncUsers)

  if ($null -ne $UserAddedCount) {
    $PListUsersAdded | Export-Csv $UserAddedCsv -NoTypeInformation
    $CSVFiles += $UserAddedCsv
  }
  if ($null -ne $UserRemovedCount) {
    $PListUsersRemoved | Export-Csv $UserremovedCsv -NoTypeInformation
    $CSVFiles += $UserRemovedCsv
  }
}
catch {
  Write-Output $_.Exception.Message
}

$HTML += "<h4>See Attached CSV Report(s)</h4>"
$HTML += "<h4>Script Started: $($ScriptStartedTime)</h4>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$EmailParams = @{
  To          = "sconnea@sonymusic.com", "Alex.Moldoveanu@sonymusic.com", "bobby.thomas@sonymusic.com", "heather.guthrie@sonymusic.com", "brian.lynch@sonymusic.com", "Rohan.Simpson@sonymusic.com"
  CC          = "jorge.ocampo.peak@sonymusic.com", "Steve.Kenton@sonymusic.com", "suminder.singh.itopia@sonymusic.com"
  From        = 'PwSh Alerts poshalerts@sonymusic.com'
  Subject     = "Azure MFA Registration Report"
  SmtpServer  = 'cmailsony.servicemail24.de'
  Body        = ($HTML | Out-String)
  BodyAsHTML  = $true
  Attachments = $CSVFiles
}

Send-MailMessage @EmailParams
Start-Sleep -Seconds 5
foreach ($Item in $CSVFiles) {
  Remove-Item $item
}
# finished for now
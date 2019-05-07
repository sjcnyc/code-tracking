using namespace System.Collections.Generic

Import-Module PSHTMLTable

#$AutomationPSCredentialName = "t2_cloud_cred"
#$Credential = Get-AutomationPSCredential -Name $AutomationPSCredentialName -ErrorAction Stop

#Connect-MsolService #-Credential $Credential -ErrorAction SilentlyContinue
#Connect-AzureAD -Credential $Credential -ErrorAction SilentlyContinue

$PListUsersRemoved     = [List[psobject]]::new()
$AZ_GroupName          = "AZ_MFA_Everywhere"
$NoMfaGroup            = "4473c787-f522-49c2-a7bb-b416a693d58e" # AZ_MFA_Everywhere
$UserCounter           = 0
$UsersRemovedFromGroup = 0
$Date                  = (Get-Date -f yyyy-MM-dd)

$UserRemovedCsv        = "C:\support\UsersRemoved_$($AZ_GroupName)_$($Date).csv"
$ScriptStartedTime     = (Get-Date -Format G)
$g                     = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck

$CSVFiles              = @()
$MfaUsers              = @()

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

$GroupMembers = Get-MsolGroupMember -GroupObjectId $NoMfaGroup -All

foreach ($GroupMember in $GroupMembers) {
  $MfaUsers += Get-Msoluser -ObjectId $GroupMember.ObjectId
}

foreach ($User in $MfaUsers) {
  #$User | Select-Object -ExpandProperty StrongAuthenticationMethods

  $UserCounter ++

  try {
    $g.GroupIds = $NoMfaGroup
    $Group = Select-AzureADGroupIdsUserIsMemberOf -ObjectId $User.ObjectId -GroupIdsForMembershipCheck $g

  if ($Group -eq $NoMfaGroup -and $User.StrongAuthenticationMethods.Count -gt 0) {
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

if ($UsersRemovedFromGroup -eq 0) { $UserRemovedCount = '0' } else { $UserRemovedCount = $UsersRemovedFromGroup }

$SyncUsers = [PSCustomObject]@{
  'Task'          = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'        = "Remove Mfa Users from $($AZ_GroupName)"
  'Users Removed' = $UserRemovedCount
  'Users Total'   = $NoMfaGroupUserCount
}

  $HTML = New-HTMLHead -title "Remove Mfa Users from $($AZ_GroupName)" -style $Style1
  $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $SyncUsers)

  if ($UserRemovedCount -gt 0) {
    $PListUsersRemoved | Export-Csv $UserremovedCsv -NoTypeInformation
    $CSVFiles += $UserRemovedCsv
    $HTML += "<h4>See Attached CSV Report(s)</h4>"
  }

$HTML += "<h4>Script Started: $($ScriptStartedTime)</h4>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$EmailParams = @{
  To          = "sconnea@sonymusic.com"#, "Alex.Moldoveanu@sonymusic.com", "bobby.thomas@sonymusic.com", "heather.guthrie@sonymusic.com", "brian.lynch@sonymusic.com", "Rohan.Simpson@sonymusic.com"
 # CC          = "jorge.ocampo.peak@sonymusic.com", "Steve.Kenton@sonymusic.com", "suminder.singh.itopia@sonymusic.com"
  From        = 'PwSh Alerts poshalerts@sonymusic.com'
  Subject     = "Remove Mfa Users from $($AZ_GroupName)"
  SmtpServer  = 'cmailsony.servicemail24.de'
  Body        = ($HTML | Out-String)
  BodyAsHTML  = $true
}

if ($CSVFiles) {
  Send-MailMessage @EmailParams -Attachments $CSVFiles
  Start-Sleep -Seconds 5
  foreach ($Item in $CSVFiles) {
    Remove-Item $item
  }
}
else {
  Send-MailMessage @EmailParams
}
using namespace System.Collections.Generic

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

$AutomationPSCredentialName = "t2_cloud_cred"
$Credential = Get-AutomationPSCredential -Name $AutomationPSCredentialName -ErrorAction Stop

Connect-MsolService -Credential $Credential -ErrorAction SilentlyContinue
Connect-AzureAD -Credential $Credential -ErrorAction SilentlyContinue

$PSList = [List[psobject]]::new()
$PListUsersAdded = [List[psobject]]::new()
$Date = (get-date -f yyyy-MM-dd)
$CSVFile = "C:\support\MFAUserReport_$($Date).csv"
$UserCsv = "C:\support\UsersAddedTo_AZ_OnPremOnly_NoMFA_Test_$($Date).csv"

$CSVFiles =@($CSVFile)

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

$UserCounter = 0
$UsersAddedToGroup = 0
$MethodTypeCount = 0
$MFAUsers = Get-Msoluser -All
$MaxUsersToDisplay = 10

$NoMfaGroup = "af67af47-8f94-45c7-a806-2b0b9f3c760e" #"AZ_OnPremOnly_NoMFA_Test"

$NonMfaUsers = $MFAUsers | Where-Object { $_.StrongAuthenticationMethods.Count -eq 0 } # -and $_.ImmutableID -eq $null

foreach ($User in $NonMfaUsers) {
  try {

    $Group = Get-IsAzGroupmember -GroupObjectId $NoMfaGroup -UserName $User.UserPrincipalName

    if ($Group -ne $true) {
      # Add-MsolGroupMember -GroupObjectId $NoMfaGroup -GroupMemberObjectId $user.ObjectId -ErrorAction Stop
      $UsersAddedToGroup ++
      Write-Output "Adding $($User.UserPrincipalName) to group.."

      $PSUserObj = [PSCustomObject]@{
        'DisplayName'       = $User.DisplayName
        'UserPrincipalName' = $User.UserPrincipalName
      }
      [void]$PListUsersAdded.Add($PSUserObj)
    }
  }
  catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
    Write-Error $_.Exception.Message  #Comment because output not required in runbook
  }
  catch {
    Write-Error $_.Exception.Message  #Comment because output not required in runbook
  }
}

$NoMfaGroupUserCount = (Get-MsolGroupMember -GroupObjectId $NoMfaGroup -All).Count

foreach ($User in $MFAUsers) {
  $UserCounter ++

  $StrongAuthenticationRequirements = $User | Select-Object -ExpandProperty StrongAuthenticationRequirements
  $StrongAuthenticationUserDetails = $User | Select-Object -ExpandProperty StrongAuthenticationUserDetails
  $StrongAuthenticationMethods = $User | Select-Object -ExpandProperty StrongAuthenticationMethods

  $MethodTypeCount += ($StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $True }).count

  $PSObj = [pscustomobject]@{
    DisplayName                                = $User.DisplayName -replace "#EXT#", ""
    UserPrincipalName                          = $user.UserPrincipalName -replace "#EXT#", ""
    IsLicensed                                 = $user.IsLicensed
    MFAState                                   = $StrongAuthenticationRequirements.State
    RememberDevicesNotIssuedBefore             = $StrongAuthenticationRequirements.RememberDevicesNotIssuedBefore
    StrongAuthenticationUserDetailsPhoneNumber = $StrongAuthenticationUserDetails.PhoneNumber
    StrongAuthenticationUserDetailsEmail       = $StrongAuthenticationUserDetails.Email
    DefaultStrongAuthenticationMethodType      = ($StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $True }).MethodType
  }
  [void]$PSList.Add($PSObj)
}

$InfoBody = [pscustomobject]@{
  'Task'            = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'          = "Azure MFA Registration Report"
  'Mfa Users Total' = $MethodTypeCount
  'Users Total'     = $UserCounter
}

if ($UsersAddedToGroup -eq 0) { $UserCount = '0' } else { $UserCount = $UsersAddedToGroup }

$SyncUsers = [PSCustomObject]@{
  'Add to Group' = "AZ_OnPremOnly_NoMFA_Test"
  'Users Added'  = $UserCount
  'Users Total'  = $NoMfaGroupUserCount
}

$PSList | Export-Csv $CSVFile -NoTypeInformation

$HTML = New-HTMLHead -title "Azure MFA Registration Report" -style $Style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
$HTML += "<h4>&nbsp;</h4>"
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $SyncUsers)
$HTML += "<h4>&nbsp;</h4>"
if ($UserCount -ne 0 -and $UserCount -le $MaxUsersToDisplay) {
  $HTML += New-HTMLTable -InputObject $($PListUsersAdded)
}
else {
  $PListUsersAdded | Export-Csv $UserCsv -NoTypeInformation
  $CSVFiles += $UserCsv
}
$HTML += "<h4>See Attached CSV Report</h4>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$EmailParams = @{
  To          = "sconnea@sonymusic.com" #, "Alex.Moldoveanu@sonymusic.com", "bobby.thomas@sonymusic.com", "Rohan.Simpson@sonymusic.com"
  #CC          = "jorge.ocampo.peak@sonymusic.com", "suminder.singh.itopia@sonymusic.com"
  From        = 'PwSh Alerts poshalerts@sonymusic.com'
  Subject     = "Azure MFA Registration Report"
  SmtpServer  = 'cmailsony.servicemail24.de'
  Body        = ($HTML | Out-String)
  BodyAsHTML  = $true
  Attachments = $CSVFiles
}

Send-MailMessage @EmailParams
Start-Sleep -Seconds 5
Remove-Item $CSVFiles
# finished for now
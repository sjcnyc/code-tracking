$AutomationPSCredentialName = "t2_cloud_cred"

$Date = (get-date -f yyyy-MM-dd)
$CSVFile = "C:\support\MFAUserReport_$($Date).csv"
$PSArrayList = New-Object System.Collections.ArrayList
$Credential = Get-AutomationPSCredential -Name $AutomationPSCredentialName -ErrorAction Stop

$Style1 =
'<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 10pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
  </style>'

Connect-MsolService -Credential $Credential -ErrorAction SilentlyContinue

$MFAUsers = Get-Msoluser -all
$UserCounter = 1
$methodTypeCount = 0

foreach ($User in $MFAUsers) {
  $UserCounter += 1

  $StrongAuthenticationRequirements = $User | Select-Object -ExpandProperty StrongAuthenticationRequirements
  $StrongAuthenticationUserDetails = $User | Select-Object -ExpandProperty StrongAuthenticationUserDetails
  $StrongAuthenticationMethods = $User | Select-Object -ExpandProperty StrongAuthenticationMethods

  $methodTypeCount += ($StrongAuthenticationMethods | Where-Object {$_.IsDefault -eq $True}).count

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
    DefaultStrongAuthenticationMethodType      = ($StrongAuthenticationMethods |Where-Object {$_.IsDefault -eq $True}).MethodType
  }
  [void]$PSArrayList.Add($PSObj)
}

$InfoBody = [pscustomobject]@{
  'Task'              = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'            = "Azure MFA Registration Report"
  'Total Users'       = $UserCounter
  'Total MFA Users'   = $methodTypeCount
}

$PSArrayList |Export-Csv $CSVFile -NoTypeInformation

$HTML = New-HTMLHead -title "Azure MFA Registration Report" -style $Style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
$HTML += "<h4>See Attached CSV Report</h4>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" |Close-HTML

$EmailParams = @{
  To          = "sconnea@sonymusic.com", "Alex.Moldoveanu@sonymusic.com", "bobby.thomas@sonymusic.com", "Rohan.Simpson@sonymusic.com"
  cc          = "jorge.ocampo.peak@sonymusic.com", "suminder.singh.itopia@sonymusic.com"
  From        = 'PwSh Alerts poshalerts@sonymusic.com'
  Subject     = "Azure MFA Registration Report"
  SmtpServer  = 'cmailsony.servicemail24.de'
  Body        = ($HTML |Out-String)
  BodyAsHTML  = $true
  Attachments = $CSVFile
}

Send-MailMessage @EmailParams
Start-Sleep -Seconds 5
Remove-Item $CSVFile
$Date = (Get-Date -f yyyy-MM-dd)
$CSVFile = "C:\Temp\MFA_Registration_Report_$($Date).csv"
$PSArrayList = New-Object System.Collections.ArrayList

Write-Output 'Connecting to Msol'
Connect-MsolService

Write-Output 'Getting All Users'
$MFAUsers = Get-MsolUser -All
$UserCounter = 0
$methodTypeCount = 0

foreach ($User in $MFAUsers) {
  $UserCounter ++

  $StrongAuthenticationRequirements = $User | Select-Object -ExpandProperty StrongAuthenticationRequirements
  $StrongAuthenticationUserDetails = $User | Select-Object -ExpandProperty StrongAuthenticationUserDetails
  $StrongAuthenticationMethods = $User | Select-Object -ExpandProperty StrongAuthenticationMethods

  $methodTypeCount += ($StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $True }).count

  $PSObj = [pscustomobject]@{
    DisplayName                                = $User.DisplayName -replace '#EXT#', ''
    UserPrincipalName                          = $User.UserPrincipalName -replace '#EXT#', ''
    ObjectId                                   = $User.ObjectId
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
  [void]$PSArrayList.Add($PSObj)
}

$PSArrayList | Export-Csv $CSVFile -NoTypeInformation
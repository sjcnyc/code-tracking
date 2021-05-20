<# Get-MsolUser -All | Select-Object @{N = 'UserPrincipalName'; E = { $_.UserPrincipalName } },

@{N = 'MFA Status'; E = { if ($_.StrongAuthenticationRequirements.State) { $_.StrongAuthenticationRequirements.State } else { "Disabled" } } },

@{N = 'MFA Methods'; E = { $_.StrongAuthenticationMethods.methodtype } } | Export-Csv -Path D:\temp\MFA_Report.csv -NoTypeInformation

#>

$users1 = Get-AzADUser | Where-Object { $_.userprincipalname -match "#EXT#" } | Select-Object *


Get-AzureADUser | Where-Object { $_.userprincipalname -match "#EXT#" } | Select-Object *




$MFAUsers = Get-MsolUser -UserPrincipalName Sean.Connealy.Admin@SonyMusicEntertainment.onmicrosoft.com

$results =
foreach ($user in $MFAUsers) {


  $StrongAuthenticationRequirements = $User | Select-Object -ExpandProperty StrongAuthenticationRequirements
  $StrongAuthenticationMethods = $User | Select-Object -ExpandProperty StrongAuthenticationMethods

  [pscustomobject]@{
    UserPrincipalName                     = $user.UserPrincipalName -replace "#EXT#", ""
    IsLicensed                            = $user.IsLicensed
    MFAState                              = ($StrongAuthenticationRequirements).State
    DefaultStrongAuthenticationMethodType = ($StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $True }).MethodType
  }
}

$results  # | Export-Csv D:\Temp\MFA_Report.csv -NoTypeInformation
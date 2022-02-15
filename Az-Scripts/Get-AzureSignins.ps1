$UPNList = 'blightyear@thesysadminchannel.com', 'astark@thesysadminchannel.com', 'jsnow@thesysadminchannel.com'
 
foreach ($User in $UPNList) {
  Get-AzureADAuditSignInLogs -Filter "UserPrincipalName eq '$User'" -Top 1 | `
    Select-Object CreatedDateTime, UserPrincipalName, IsInteractive, AppDisplayName, IpAddress, TokenIssuerType, @{Name = 'DeviceOS'; Expression = { $_.DeviceDetail.OperatingSystem } }
}
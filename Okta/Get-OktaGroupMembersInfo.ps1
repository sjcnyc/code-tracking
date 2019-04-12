$Params = @{
  Properties = 'SamAccountName',
               'DisplayName',
               'mail',
               'UserPrincipalName',
               'CanonicalName',
               'Description',
               'Enabled',
               'Lockedout',
               'PasswordNeverExpires',
               'PasswordLastSet',
               'PasswordExpired',
               'LastLogonTimestamp',
               'DistinguishedName'
}
(Get-ADGroup "Okta_SonyMusic.com" -Prop Member -Server 'me.sonymusic.com').Member | Get-ADUser @Params -Server 'me.sonymusic.com'|
Select-Object $Params.Properties | Export-Csv C:\temp\Okta_SonyMusic_0015.csv -NoTypeInformation
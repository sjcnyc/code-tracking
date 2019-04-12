$CSVFile = "C:\temp\Okta_SonyMusic_$(get-date -f yyyy-MM-dd).csv"
$getaduserSplat = @{
  Properties = 'SamAccountName', 'DisplayName', 'mail', 'UserPrincipalName', 'CanonicalName', 'Description', 'Enabled', 'Lockedout', 'PasswordNeverExpires', 'PasswordLastSet', 'PasswordExpired', 'LastLogonTimestamp', 'WhenCreated'
}

$selectObjectSplat = @{
    Property = 'SamAccountName', 'DisplayName', 'UserPrincipalName', 'CanonicalName', 'Description', 'Enabled', 'Lockedout', 'PasswordNeverExpires', 'PasswordLastSet', 'PasswordExpired', @{N = 'LastLogonTimeStamp'; E = {[datetime]::FromFileTime($_.lastLogonTimestamp).ToString('g')}}, 'WhenCreated'
}
(Get-ADGroup "Okta_SonyMusic.com" -Prop Member -Server 'me.sonymusic.com').Member |Get-ADUser @getaduserSplat -Server 'me.sonymusic.com' |Select-Object @selectObjectSplat |
  Export-Csv $CSVFile -NoTypeInformation


((Get-ADGroup "Okta_SonyMusic.com" -Prop Member -Server 'me.sonymusic.com').Member).Count
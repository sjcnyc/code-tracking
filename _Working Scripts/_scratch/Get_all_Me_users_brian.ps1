$getADUserSplat = @{
    Server     = "me.sonymusic.com"
    SearchBase = "DC=me,DC=sonymusic,DC=com"
    Filter     = '*'
    Properties = 'UserPrincipalname', 'SamAccountName', 'DistinguishedName', 'PasswordNeverExpires', 'PasswordNotRequired', 'Enabled', 'PasswordLastSet', 'PasswordExpired'
}
Get-ADUser @getADUserSplat |Select-Object $getADUserSplat.Properties |Export-Csv C:\Temp\All_Me_Users.csv -NoTypeInformation
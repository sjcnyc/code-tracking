
$getADUserSplat = @{
    Filter     = '*'
    Properties = 'GivenName', 'Surname', 'Samaccountname', 'DistinguishedName', 'PasswordNeverExpires', 'PasswordNotRequired', 'Enabled', 'PasswordLastSet', 'PasswordExpired'
}

Get-ADUser @getADUserSplat | Select-Object $getADUserSplat.Properties | Export-Csv D:\Temp\user_password_info.csv -NoTypeInformation

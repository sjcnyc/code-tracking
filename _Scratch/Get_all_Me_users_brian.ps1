$Date = (Get-Date -f yyyy-MM-dd)
$CSVFile = "C:\Temp\AllUserMeReport_$($Date).csv"
function Convert-LLTS ($LLTS) { $LLTS = [DateTime]::FromFileTime($LLTS) }

$getADUserSplat = @{
    Server     = "me.sonymusic.com"
    SearchBase = "DC=me,DC=sonymusic,DC=com"
    Filter     = '*'
    Properties = 'UserPrincipalname', 'SamAccountName', 'CanonicalName', 'PasswordNeverExpires', 'PasswordNotRequired', 'Enabled', 'PasswordLastSet', 'PasswordExpired', 'LastLogonTimeStamp'
}


Get-ADUser @getADUserSplat | Select-Object UserPrincipalname, SamAccountName, CanonicalName, PasswordNeverExpires, PasswordNotRequired, Enabled, PasswordLastSet, PasswordExpired, @{N = 'LastLogonTimeStamp'; E = { [DateTime]::FromFileTime($_.LastLogonTimeStamp) } } | Export-Csv $CSVFile -NoTypeInformation

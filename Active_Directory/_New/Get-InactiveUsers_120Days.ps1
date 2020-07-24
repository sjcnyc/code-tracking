Get-ADUser -Filter * -Properties Name, Lastlogontimestamp, PasswordNeverExpires |
Where-Object {([datetime]::FromFileTime($_.lastlogontimestamp) -le (Get-Date).adddays(-120)) -and ($_.passwordNeverExpires -ne "true") } |
    Select-Object Name, PasswordNeverExpires, @{N = 'Lastlogontimestamp'; E = {([datetime]::FromFileTime($_.lastlogontimestamp))}}, AccountIsDisabled |
    Export-Csv C:\Temp\users_olderThan_120Days.csv -NoTypeInformation


Get-QADUser -SearchScope Subtree -SizeLimit 0 |
Select-Object Name, PasswordNeverExpires, AccountIsDisabled, LastLogonTimeStamp, SamAccountName |
    Where-Object {$_.LastLogonTimeStamp -ne $Null -and ((Get-Date) - $_.LastLogonTimeStamp).Days -gt '120' } |
    Export-Csv C:\Temp\users_olderThan_120Days.csv -NoTypeInformation


(Get-QADUser -SearchScope Subtree -SizeLimit 0).Where{$_.LastLogonTimeStamp -ne $Null -and ((Get-Date) - $_.LastLogonTimeStamp).Days -gt '120' } |
    Select-Object Name, PasswordNeverExpires, AccountIsDisabled, LastLogonTimeStamp, SamAccountName, AccountExpires |
    Export-Csv C:\Temp\users_olderThan_120Days.csv -NoTypeInformation

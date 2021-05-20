Get-QADUser -SizeLimit 0 -SearchRoot "me.sonymusic.com/Tier-2/STD/NA/USA/GBL/Users" -Service 'me.sonymusic.com' |
    Select-Object FirstName, LastName, SamAccountName, whenCreated, LastLogon, ModificationDate, ParentContainer |
    Export-Csv C:\Temp\ME_USA_Users.csv -NoTypeInformation
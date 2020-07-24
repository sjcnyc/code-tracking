Get-Mailbox -ResultSize Unlimited |
    Where-Object { $_.whenCreated -ge (get-date "January 1, 2017") -and $_.whenCreated -le (get-date "March 28, 2017")} |
    Select-Object DisplayName, PrimarySmtpAddress, SamAccountName, DistinguishedName, WhenCreated -ErrorAction 0 |
    Export-CSV c:\temp\Export002.csv -NoTypeInformation

Get-Mailbox -ResultSize Unlimited |
    Where-Object { $_.whenCreated -ge (get-date "January 1, 2017") -and $_.whenCreated -le (get-date "March 28, 2017")} |
    Select-Object DisplayName, PrimarySmtpAddress, SamAccountName, DistinguishedName, WhenCreated, OrganizationalUnit -ErrorAction 0 |
    Export-CSV -Path 'c:\temp\Export005.csv' -NoTypeInformation
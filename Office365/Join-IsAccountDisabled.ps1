function Get-AccountStatus {
    param(
        [string]$user
    )

    if (!( Get-ADUser -Filter {
                ( SamAccountName -eq $user ) 
            })) {
        'NotExist' 
    }
    elseif ((Get-ADUser $user).enabled -eq 'True') {
        'Enabled'
    }
    else {
        'Disabled'
    }
}

Import-Csv -Path 'C:\temp\MailboxReport_13.04.2017.csv' |
    Select-Object -Property *, @{
    Name = 'AccountStatus'
    Expression = {
        (Get-AccountStatus -user $_.Alias)
    }
} |
    Export-Csv -Path 'c:\temp\join9.csv' -NoTypeInformation
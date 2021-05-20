<#Get-ADUser -SearchBase 'OU=NewSync,OU=USR,OU=GBL,OU=USA,OU=zLegacy,DC=me,DC=sonymusic,DC=com' -Filter {
    Enabled -eq $true
} -Properties msDS-UserPasswordExpiryTimeComputed, DisplayName, EmailAddress |
    Select-Object -Property 'SamAccountName', 'DisplayName', 'EmailAddress', @{
    Name = 'MustChangePass'
    Expression = {
        if ($_.'msDS-UserPasswordExpiryTimeComputed' -eq 0) {
            'True'
        }
        else {
            'False'
        }
    }
} | Export-Csv c:\temp\userMustChangePass_005.csv -NoTypeInformation#>

$result = New-Object -TypeName System.Collections.ArrayList
$users = Import-Csv 'C:\Temp\userMustChangePass_004.csv'

foreach ($user in $users) {
    $BMGuser = Get-ADUser -Identity $user.SamAccountName -filter {
        Enabled -eq $true
    } -Properties 'SamAccountName', @{
        Name = 'MustChangePassBMG'
        Expression = {
            if ($_.'msDS-UserPasswordExpiryTimeComputed' -eq 0) {
                'True'
            }
            else {
                'False'
            }
        }
    }
    $info = [pscustomobject]@{
        'SamAccountName'    = $user.SamAccountName
        'DisplayName'       = $user.DisplayName
        'EmailAddress'      = $user.EmailAddress
        'MustChangePass'    = $user.MustChangePass
        'MustChangePassBMG' = $BMGuser.MustChangePassBMG
    }
    $null = $result.Add($info)
}

$result
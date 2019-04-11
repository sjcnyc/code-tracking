# UPN, FirstName, LastName, Email, AccountActive/Disabled, Country or location

# USER_ID	AD_USER_NM	LAST_LOGIN

$users = @"
Farley.Barbara
"@ -split [System.Environment]::NewLine#

#$users = Import-Csv C:\temp\active_drd_users.csv

foreach ($user in $users) {
    Get-QADUser "Moldoveanu, Alex" -IncludeAllProperties -Service 'me.sonymusic.com' |
        Select-Object UserPrincipalName | ft -auto # Out-File c:\temp\names.txt -Encoding utf8 -Append #, FirstName, lastName, Mail, @{N = 'AccountStatus'; E = {if ($_.AccountIsDisabled -eq 'TRUE') {'Disabled'}else {'Enabled'}}}
    <#
    $PSObj               = [pscustomobject]@{
        'USER_ID'        = $user.USER_ID
        'AD_USER_NM'     = $user.AD_USER_NM
        'LAST_LOGIN'     = $user.LAST_LOGIN
        'UPN'            = $userprops.UserPrincipalName
        'FirstName'      = $userprops.FirstName
        'LastName'       = $userprops.LastName
        'Email'          = $userprops.Mail
        'Account'        = $userprops.AccountStatus
    }
    $PSObj | Export-Csv C: \Temp\avtive_drd_users_w_UPN.csv -NoTypeInformation -Append
    #>
}
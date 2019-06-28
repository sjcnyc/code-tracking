
#Sno	Username	First Name	Last Name	Email Address

$users = Import-Csv 'C:\temp\Copy of AOMA Users - Jan25 2018 - Revised.csv'

foreach ($user in $users) {
    $userprops = Get-QADUser $user.Username -IncludeAllProperties -Service 'me.sonymusic.com' | Select-Object UserPrincipalName

    $PSObj = [pscustomobject]@{
        'Sno'           = $user.Sno
        'Username'      = $user.Username
        'First Name'    = $user."First Name"
        'Last Name'     = $user."Last Name"
        'Email Address' = $user."Email Address"
        'UPN'           = $userprops.UserPrincipalName
    }
    $PSObj | Export-Csv C:\Temp\Aoma_users_w_UPN.csv -NoTypeInformation -Append
}
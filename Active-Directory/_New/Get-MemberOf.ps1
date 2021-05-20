function script:Get-MemberOf {
    param
    (
        [Parameter(Mandatory)][string]$user,
        [Parameter(Mandatory)][string]$group
    )

    $groups = Get-QADUser $user -Service "me.sonymusic.com" | Select-Object -ExpandProperty MemberOf
    if ($groups -match $group) {"Yes"} else {"No"}
}

$PSArray = New-Object System.Collections.ArrayList
$users = Import-Csv -Path C:\temp\apollo-accounts.csv
$group = "CN=Okta_SonyMusic.com,OU=Tasks,OU=Groups,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-1,DC=me,DC=sonymusic,DC=com"

foreach ($user in $users) {

    $PSObj = [pscustomobject]@{

        'Username'             = $user.Name
        'SamAccountName'       = (Get-QADUser $user.Email -Service 'me.sonymusic.com' | Select-Object -ExpandProperty SamAccountName)
        'Email'                = $user.Email
        'Country'              = $user.Country
        'APOLLO_MemberOf_Okta' = (Get-MemberOf -user $user.Email -group $group)
        'AccountIsDisabled'    = (Get-QADUser $user.Email -Service 'me.sonymusic.com' | Select-Object -ExpandProperty AccountIsDisabled)
    }
     [void]$PSArray.Add($PSObj)
}

$PSArray | Export-Csv C:\temp\APOLLO_User_List_final_3.csv -NoType


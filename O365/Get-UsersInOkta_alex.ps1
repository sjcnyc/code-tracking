$users =@"
DEIC007
SNEL005
DOOL001
SCOT049
GULL012
bmcgint
RIZZ007
MOXE001
SWOG001
RAPP017
MARN003
KAPL010
MCKI008
"@ -split [environment]::NewLine

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
#$users = Import-Csv -Path C:\temp\apollo-accounts.csv
$group = "CN=Okta_SonyMusic.com,OU=Tasks,OU=Groups,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-1,DC=me,DC=sonymusic,DC=com"

foreach ($user in $users) {

    $PSObj = [pscustomobject]@{

        'Username'             = $user
        'SamAccountName'       = (Get-QADUser $user -Service 'me.sonymusic.com' | Select-Object -ExpandProperty SamAccountName | Out-String).Trim()
        'Email'                = (Get-Qaduser $user -service 'me.sonymusic.com' -IncludeAllProperties | Select-Object -ExpandProperty Mail)
        'APOLLO_MemberOf_Okta' = (Get-MemberOf -user $user -group $group)
        'AccountIsDisabled'    = (Get-QADUser $user -Service 'me.sonymusic.com' | Select-Object -ExpandProperty AccountIsDisabled | Out-String).Trim()
    }
    [void]$PSArray.Add($PSObj)
}

$PSArray #| Export-Csv C:\temp\APOLLO_User_List_final_445.csv -NoType
<#$result = New-Object -TypeName System.Collections.ArrayList

$users = Get-MsolUser -All | Where-Object {$_.UserPrincipalName -like '*admin*'}|

 Select-Object StrongAuthenticationRequirements, UserPrincipalName 
  
    
foreach ($user in $users) {
    
    $info = [pscustomobject]@{

        'UserPrincipalName' = $user.UserPrincipalName
        'MFAState' = if (($user | Select-Object -ExpandProperty StrongAuthenticationRequirements).State -eq 'Enforced'){'Enabled'}else{'Disabled'}
    }

    $info | Export-Csv 'C:\Temp\MSOLAdminMFAState.csv' -NoTypeInformation -Append
}
#>


$MSOLRolls = Get-MsolRole

foreach ($roll in $MSOLRolls) {

    Get-MsolRoleMember -RoleObjectId $roll.ObjectID | Select-Object EmailAddress, DisplayName |
        ForEach-Object -Process {

        $info = [pscustomobject]@{
            'DosplayName'         = $_.DisplayName
            'UserPrincipalName'   = $_.EmailAddress
            'MFAState'            = if ((Get-MsolUser -UserPrincipalName $_.EmailAddress -ErrorAction Ignore | Select-Object -ExpandProperty StrongAuthenticationRequirements).State -eq 'Enforced') {'Enabled'} else {'Disabled'}
            'MSOLRoll'            = $roll.name
            'MSOLRollDescription' = $roll.Description
        }
        $info | Export-Csv C:\Temp\MSOLRollMemberMFAState.csv -NoTypeInformation -Append
    }
}
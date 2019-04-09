$users_src = import-csv 'C:\temp\List_of_Users_All_20180314.csv'

foreach ($user in $users_src) {

    $var  = Get-QADUser -Identity $user.'Login Identifier *' | Select-Object SamAccountName, AccountIsDisabled
    $var2 = Get-QADUser -Identity $user.email | Select-Object SamAccountName, AccountIsDisabled

    $psobject = [pscustomobject]@{

        'First name *'       = $user.'First name *'
        'Middle name'        = $user.'Middle name'
        'Last Name *'        = $user.'Last Name *'
        'email'              = $user.email
        'Region'             = $user.Region
        'Standard Label'     = $user.'Standard Label'
        'Login Identifier *' = $user.'Login Identifier *'
        'SamAccountName'     = $var.SamAccountName
        'AccountIsDisabled'  = $var.AccountIsDisabled
        'AccountExists'      = if ($var -eq $null) {"False"} else {"True"}
        'SamAccountName2'    = $var2.SamAccountName
    }

    $psobject | Export-Csv C:\temp\List_of_Users_All_20180315_New.csv -NoTypeInformation -Append
}
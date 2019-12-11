$List = Get-ADUser -Filter * -Properties DisplayName,samaccountname,mail,memberof, UserPrincipalName | Select-Object -First 10 |
    ForEach-Object {
        $User = $_
        $User.memberof |
            ForEach-Object {
            [PSCustomObject]@{
                DisplayName    = $User.DisplayName
                SamAccountName = $User.samaccountname
                Mail       = $User.mail
                UPN        = $User.UserPrincipalName
                Group      = Get-ADGroup -Identity $_ | Select-Object -ExpandProperty Name
            }
        }
    }

$List | Out-GridView
Connect-Graph

$getADUserSplat = @{
    Properties = 'MemberOf', 'Lastlogontimestamp', 'Enabled', 'userPrincipalName', 'samAccountName', 'displayName', 'givenName', 'surName'
    Filter     = { (sAMAccountName -like "adm*-*") }
}



#Connect-MgGraph

    $Users = Get-ADUser @getADUserSplat

    $Output = @()
    foreach ($User in $Users) {

        $Name = "$($user.GivenName) $($user.Surname)"
        $Name2 = "$($user.Surname), $($user.GivenName)"

        $filter = "(Name -like '$Name*') -or (Name -like '$Name2*')"

        $aduser =  Get-ADUser -Filter $filter -prop userPrincipalName, samAccountName, displayName, givenName, surName, Name|
            Where-Object {$_.Enabled -eq $true} |
            Select-Object userPrincipalName, samAccountName, displayName, givenName, surName, Name

        $userPrincipalname = $aduser.userPrincipalName

        $aaduser = Get-MgUser -Filter "userPrincipalName eq '$userPrincipalname'" | Select-Object id, userPrincipalName, displayName

        if ($aaduser) {
            $Output += [PSCustomObject]@{
                DisplayName         = "$($aduser.Name)"
                UserName            = "$($User.Name)"
                userPrincipalName   = "$($aduser.userPrincipalname)"
                ExtensionAttribute2 = "$($aaduser.id) | $($UserPrincipalName)"
            }

            Set-ADUser -Identity $aduser.samAccountName -Replace @{extensionAttribute2 = $Output.ExtensionAttribute2} #-WhatIf

        } else {
            $Output += [PSCustomObject]@{
                DisplayName         = "Not Found"
                UserName            = "$($User.Name)"
                userPrincipalName   = "Not Found"
                ExtensionAttribute2 = "Not Found"
            }
        }
    }

    $Output | Export-Csv -Path "C:\temp\ADUsers.csv" -NoTypeInformation
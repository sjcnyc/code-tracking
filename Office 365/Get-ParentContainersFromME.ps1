Import-Module -Name ActiveDirectory
$users = Import-Csv -Path 'C:\temp\Export006.csv'

$result = New-Object -TypeName System.Collections.ArrayList

Foreach ($user in $users) {  
    $UserDn = Get-ADUser -Identity $user.SamAccountName | Select-Object -Property Distinguishedname
    $parentContainer = (([adsi]"LDAP://$($UserDn.DistinguishedName)").Parent).Substring(7)

    $info = [pscustomobject]@{
        'SamAccountName'    = $user.SamAccountName
        'DistinguishedName' = $user.DistinguishedName
        'DisplayName'       = $user.DisplayName
        'ParentContainer'   = $parentContainer
    }
    $null = $result.Add($info)
}

$result | Export-Csv -Path 'c:\temp\ME_parentcontainers.csv' -NoTypeInformation
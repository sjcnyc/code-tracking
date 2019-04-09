$users = @"
SEMU001
SHAR002
"@ -split [environment]::NewLine

foreach ($user in $users) {
    try {

        $userDN = get-aduser $user | Select-Object distinguishedname | select-object DistinguishedName
        $ou = 'OU=Non-Employees,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com'
        Move-ADObject -Identity $userDN -TargetPath $ou
        Write-Output -InputObject ('Moving User: {0} to: {1}' -f $userDN.distinguishedname, $ou)
    }
    catch {
        $_.Exception.Message
    }
}
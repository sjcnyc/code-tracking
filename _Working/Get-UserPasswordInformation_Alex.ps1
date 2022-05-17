$OUs = @'
OU=Employees,OU=Users,OU=RIO,OU=BRA,OU=LA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=Non-Employees,OU=Users,OU=RIO,OU=BRA,OU=LA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
'@ -split [environment]::newline

$Users =
    foreach ($OU in $OUs) {
        $getADUserSplat = @{
            Filter     = '*'
            SearchBase = $ou
            Properties = 'GivenName', 'Surname', 'Samaccountname', 'DistinguishedName', 'PasswordNeverExpires', 'PasswordNotRequired', 'Enabled', 'PasswordLastSet', 'PasswordExpired'
        }

        Get-ADUser @getADUserSplat | Select-Object $getADUserSplat.Properties
    }

$Users | Export-Csv D:\Downloads\report3.csv -NoTypeInformation
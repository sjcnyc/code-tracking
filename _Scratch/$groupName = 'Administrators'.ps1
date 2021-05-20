$groupName = 'Administrators'
$group = "LDAP://CN=$($GroupName),OU=Roles,OU=Groups,DC=company,DC=ca"
$group = [ADSI]$group




$email = "foo@bar.com"
($email.Substring(0, $email.IndexOf("@")).ToUpper() + $email.substring($email.IndexOf("@")))





$Test = "r2606:4700:4700:0:0::1111x,2606:4700:4700::1001,10.0.0.1,23.23.253.1c bob 10.0.0.1 2606:4700:4700::1001rt"

$Test -split " |,|;" -replace "[^:\d]" |
ForEach-Object { $PSItem -as [ipaddress] } | Format-Table

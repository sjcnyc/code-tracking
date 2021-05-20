$ADUserSplat = @{
  Filter     = { (Enabled -eq $True) }
  Properties = 'sAMAccountName', 'givenName', 'sn', 'enabled', 'CanonicalName', 'whenCreated', 'whenChanged', 'LastLogonTimeStamp'
}

$Users = @()

$ous =
"OU=Employees,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com",
"OU=Non-Employees,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com",
"OU=LOH,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"

foreach ($ou in $ous) {
  $Users += Get-ADUser -SearchBase $ou @ADUserSplat |
  Select-Object 'sAMAccountName', 'givenName', 'sn', 'enabled', 'CanonicalName', 'whenCreated', 'whenChanged', @{n = 'LastLogon'; e = { [DateTime]::FromFileTime($_.LastLogonTimeStamp) } }
}

$Users | Export-Csv -Path D:\Temp\ME_Users1_$(Get-Date -f {MMdyyyyhhmm}).csv -NoTypeInformation
Write-Output "Total User Count: $($Users.Count)"

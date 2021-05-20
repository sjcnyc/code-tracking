$OUs =
@"
OU=AP,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=EU,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=LA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=CAN,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=Employees,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=LOH,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=Non-Employees,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
"@ -split [environment]::NewLine

foreach ($OU in $OUs) {
  $getADUserSplat = @{
    SearchBase = $OU
    Properties = 'Name', 'SamAccountName', 'DistinguishedName'
    Server     = 'me.sonymusic.com'
    Filter     = { enabled -eq $true }
  }
  Get-ADUser @getADUserSplat | Export-Csv C:\Temp\enabled_users_me2.csv -NoTypeInformation -Append
}
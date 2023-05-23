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

#foreach ($OU in $OUs) {
  $getADUserSplat = @{
    SearchBase = "OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
    Properties = 'Name', 'SamAccountName', 'DistinguishedName', 'Enabled'
    Server     = 'me.sonymusic.com'
    Filter     = { enabled -eq $true }
  }
  Get-ADUser @getADUserSplat | Select-Object $getADUserSplat.Properties | Export-Csv C:\Temp\enabled_users_me.csv -NoTypeInformation
#}
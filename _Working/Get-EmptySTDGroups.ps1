$getADGroupSplat = @{
    LDAPFilter = "(&(!(member=*)))"
    Properties = 'CanonicalName'
    SearchBase = 'OU=Groups,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com'
}

Get-ADGroup @getADGroupSplat | Select-Object Name, CanonicalName | Export-Csv D:\Temp\Empty_STD_Groups.csv
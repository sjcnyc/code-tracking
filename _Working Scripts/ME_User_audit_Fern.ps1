$ous =
@"
OU=Employees,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=LOH,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
OU=Non-Employees,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
"@ -split [environment]::NewLine

$users = @()
foreach ($ou in $ous) {
  $getQADUserSplat = @{
      SearchRoot = $ou
      SizeLimit = 0
      DontUseDefaultIncludedProperties = $true
      IncludedProperties = 'SamAccountName', 'DisplayName', 'WhenCreated', 'whenChanged', 'LastLogonTimeStamp', 'AccountIsDisabled', 'ParentContainer'
      Enabled = $true
  }

  $users += Get-QADUser @getQADUserSplat | Select-Object $getQADUserSplat.IncludedProperties
}
$users | Export-Csv D:\Temp\ME_Users_0004.csv -NoTypeInformation
Clear-Host
Write-Output "User Count: $($users.Length)"
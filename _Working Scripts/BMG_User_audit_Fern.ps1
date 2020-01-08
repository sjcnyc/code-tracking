$ous =
@"
me.sonymusic.com/Tier-0
me.sonymusic.com/Tier-1
me.sonymusic.com/Tier-2
"@ -split [environment]::NewLine

$users = @()
foreach ($ou in $ous) {
  $getQADUserSplat = @{
      SearchRoot = $ou
      SizeLimit = 0
      DontUseDefaultIncludedProperties = $true
      IncludedProperties = 'SamAccountName', 'DisplayName', 'WhenCreated', 'whenChanged', 'LastLogonTimeStamp', 'AccountIsDisabled', 'ParentContainer'
      #Enabled = $true
  }
  $selectObjectSplat = @{
      Property = 'SamAccountName', 'DisplayName', 'WhenCreated', 'whenChanged', 'LastLogonTimeStamp', 'AccountIsDisabled', 'ParentContainer'
  }
  $users += Get-QADUser @getQADUserSplat |Select-Object @selectObjectSplat
}
$users | Export-Csv C:\Temp\ME_Users_0003.csv -NoTypeInformation
Write-Output "User Count: $($users.Length)"

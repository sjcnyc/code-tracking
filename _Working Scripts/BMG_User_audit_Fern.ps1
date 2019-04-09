$ous =
@"
bmg.bagint.com/USA/GBL/USR/CMR
bmg.bagint.com/USA/GBL/USR/Employees
bmg.bagint.com/USA/GBL/USR/ES Royalties
bmg.bagint.com/USA/GBL/USR/Interns
bmg.bagint.com/USA/GBL/USR/LOH
bmg.bagint.com/USA/GBL/USR/Non Employee Users
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
  $selectObjectSplat = @{
      Property = 'SamAccountName', 'DisplayName', 'WhenCreated', 'whenChanged', 'LastLogonTimeStamp', 'AccountIsDisabled', 'ParentContainer'
  }
  $users += Get-QADUser @getQADUserSplat |Select-Object @selectObjectSplat
}
$users | Export-Csv C:\Temp\BMG_Users_0003.csv -NoTypeInformation
Write-Output "User Count: $($users.Length)"

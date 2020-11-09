$remoteSite        = "Miami"
$migrationFilePath = "D:\OneDrive_Migration"
$regionHomeDrives  = "$($remoteSite)_Home_drives.csv"
$ODUsersFile       = "OD_Users_Main.csv"

$results = @()

$users = @"
avila04
ARANO01
ANGE056
AANE001
sanch03
"@ -split [environment]::NewLine

foreach ($user in $users) {
  try {
    $getuser = Get-ADUser $user -Properties DisplayName, sAMAccountName | Select-Object DisplayName, sAMAccountName

    $results += [pscustomobject]@{
      DisplayName    = $getuser.DisplayName
      HomeDirectory  = "D:\production_shares\Users\$($user)"
      SamAccountName = $getuser.sAMAccountName
    }
  }
  catch {
    $_.Exception.Message
  }
}
$results | Export-Csv "$($migrationFilePath)\$($remoteSite)\$($regionHomeDrives)"

$AllUsers  = Import-Csv "$($migrationFilePath)\$($ODUsersFile)"
$HomeUsers = Import-Csv "$($migrationFilePath)\$($remotesite)\$($regionHomeDrives)"

Join-Object -Left $AllUsers -Right $HomeUsers -LeftJoinProperty DisplayName1 -RightJoinProperty DisplayName |
Export-Csv D:\OneDrive_Migration\Miami\OD_Migration_Joined.csv



<# Import-Module Sharegate
$csvFile    = "C:\MigrationPlanning\onedrivemigration.csv"
$table      = Import-Csv $csvFile -Delimiter ","
$mypassword = ConvertTo-SecureString "mypassword" -AsPlainText -Force
Set-Variable dstSite, dstList
foreach ($row in $table) {
  Clear-Variable dstSite
  Clear-Variable dstList
  $dstSite = Connect-Site -Url $row.ONEDRIVEURL -Username "myusername" -Password $mypassword
  Add-SiteCollectionAdministrator -Site $dstSite
  $dstList = Get-List -Name Documents -Site $dstSite
  Import-Document -SourceFolder $row.DIRECTORY -DestinationList $dstList
  Remove-SiteCollectionAdministrator -Site $dstSite
  Export-Report "$($migrationFilePath)\$($remotesite)"
} #>
$remoteSite = "Sean"
$migrationFilePath = "D:\Temp\OneDrive_Migration"
$regionHomeDrives = "$($remoteSite)_Home_drives.csv"
$ODUsersFile = "OD_Users_Main.csv"

$results = @()

$users = @"
sconnea
"@ -split [environment]::NewLine

foreach ($user in $users) {
  try {
    $results += Get-ADUser $user -Properties DisplayName, sAMAccountName, HomeDirectory |
    Select-Object DisplayName, sAMAccountName, HomeDirectory
  }
  catch {
    $_.Exception.Message
  }
}
$results | Export-Csv "$($migrationFilePath)\$($remoteSite)\$($regionHomeDrives)"

$AllUsers = Import-Csv "$($migrationFilePath)\$($ODUsersFile)"
$HomeUsers = Import-Csv "$($migrationFilePath)\$($remotesite)\$($regionHomeDrives)"

Join-Object -Left $AllUsers -Right $HomeUsers -LeftJoinProperty DisplayName1 -RightJoinProperty DisplayName |
Export-Csv D:\Temp\OneDrive_Migration\OD_Migration_Joined.csv -Append

<# Import-Module Sharegate
$csvFile = "C:\MigrationPlanning\onedrivemigration.csv"
$table = Import-Csv $csvFile -Delimiter ","
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
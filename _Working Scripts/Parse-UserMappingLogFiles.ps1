using namespace System.Collections.Generic
$List = [List[PSObject]]::new()

$logs = Get-ChildItem -Path "\\storage.me.sonymusic.com\logs$\" -Filter *.log -File

foreach ($log in $logs) {

  $file = Get-Content $log.FullName | Select-String User, drive

  $split = $file -split ('M:')
  $split = $split -replace (" Drive:", "")
  $split = $split -replace ("User :  ", "")

  $split = $split |
  Where-Object {
    $_ -notmatch "\d{1,2}\/\d{1,2}\/\d{1,4}" -and $_ -notmatch "^(?:(?:([01]?\d | 2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$" -and $_ -notmatch "(0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.](19|20)[0-9]{2}"
  }

  $split  = $split | Select-String -Pattern "ME\\", "storage"
  $user1  = $split | Select-String -Pattern "ME\\" -Exclude "storage"
  $drive1 = $split | Select-String -Pattern "storage." -Exclude "ME\\"

  $filtered = $drive1 | Where-Object { $_ -notmatch "H:\\*" -and $_ -notmatch "S:\\*" -and $_ -notmatch "O:\\*" -and $_ -notmatch "U:\\*" -and $_ -notmatch "V:\\*" -and $drive1 -ne "" }

  $PSObj = [pscustomobject]@{
    UserName = $user1
    Drives   = $filtered -join ","
  }

  [void]$List.Add($PSObj)
   #a| Export-Csv -Path D:\Temp\drive_mappings2.csv -NoTypeInformation -Append
}

$List | Export-Csv d:\temp\custom_mapped_drives.csv -UseCulture
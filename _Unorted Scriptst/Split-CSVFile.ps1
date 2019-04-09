function Split-CsvFile {
  param (
    [string]
    $sourceCSV,
    [int]
    $size
  )
  $exportPath = $sourceCSV.Substring(0, $sourceCSV.LastIndexOf('.'))
  $count = (Import-Csv $sourceCSV).count
  $startrow = 0;
  $counter = 1;

  while ($startrow -lt $count) {
    Import-CSV $sourceCSV | select-object -skip $startrow -first $size |
      Export-CSV "$($exportPath)_$($counter).csv" -NoClobber -Encoding UTF8
    $startrow += $size
    $counter++
  }
}

Split-CsvFile -sourceCSV '\\storage\pstholding$\SpamLogs\X-Headers-2018-01-30_12-55-15.csv' -size 5000
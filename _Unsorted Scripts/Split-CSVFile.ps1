function Split-CsvFile {
  param (
    [string]
    $SourceCSV,
    [int]
    $Size
  )
  $ExportPath = $SourceCSV.Substring(0, $SourceCSV.LastIndexOf('.'))
  $Count      = (Import-Csv $SourceCSV).Count
  $StartRow   = 0
  $Counter    = 1

  while ($StartRow -lt $Count) {
    Import-CSV $SourceCSV | select-object -Skip $StartRow -First $Size |
    Export-CSV "$($ExportPath)_$($Counter).csv" -NoClobber -Encoding UTF8
    $StartRow += $Size
    $Counter++
  }
}

Split-CsvFile -SourceCSV D:\temp\MpIsilon_Report2.csv -Size 6000
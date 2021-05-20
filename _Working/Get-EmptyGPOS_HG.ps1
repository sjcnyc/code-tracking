$Date = (get-date -f yyyy-MM-dd)
$CSVFile = "C:\temp\ME_GPO_Status$($Date).csv"
$PSArrayList = New-Object System.Collections.ArrayList

$gpos = get-gpo -All -Domain "me.sonymusic.com"

foreach ($item in $gpos) {
  if ($item.Computer.DSVersion -eq 0 -and $item.User.DSVersion -eq 0) {
    $status = "True"
  }
  else {
    $status = "False"
  }
  $PSOGPOObj = [pscustomobject]@{
    DisplayName = $item.DisplayName
    GpoStatus   = $item.GpoStatus
    Empty       = $status
  }

  [void]$PSArrayList.Add($PSOGPOObj)
}

$PSArrayList |Export-Csv $CSVFile -NoTypeInformation
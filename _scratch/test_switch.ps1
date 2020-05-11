$Days = @("Saturday, March 23, 2019", "Sunday, March 24, 2019", "Monday, March 25, 2019", "Wednesday, March 27, 2019")

$Dates=@()
for ($x = 1; $x -lt 7; $x++) {
  $Dates += (get-date).adddays($x).ToLongDateString()
}

foreach ($Day in $Days) {
  for ($i = 0; $i -lt $Dates.Length; $i++) {
    switch ($Day) {
      $Dates[0] { $result = '1' }
      $Dates[1] { $result = '2' }
      $Dates[2] { $result = '3' }
      $Dates[3] { $result = '4' }
      $Dates[4] { $result = '5' }
      $Dates[5] { $result = '6' }
      $Dates[6] { $result = '7' }
    }
  }
  $result
}
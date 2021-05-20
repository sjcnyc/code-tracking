# Database variables
$sqlserver = "sqlserver"
$database = "locations"
$table = "allcountries"

# CSV variables;
$csvfile = "C:\temp\allCountries.txt"
$csvdelimiter = "`t"
$firstrowcolumnnames = $false

Write-Output "Script started..."
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

# 100k worked fastest and kept memory usage to a minimum
$batchsize = 100000

# Build the sqlbulkcopy connection, and set the timeout to infinite
$connectionstring = "Data Source=$sqlserver;Integrated Security=true;Initial Catalog=$database;"
$bulkcopy = New-Object ("Data.SqlClient.Sqlbulkcopy") $connectionstring
$bulkcopy.DestinationTableName = $table
$bulkcopy.bulkcopyTimeout = 0
$bulkcopy.batchsize = $batchsize
$bulkcopy.EnableStreaming = 1

# Create the datatable, and autogenerate the columns.
$datatable = New-Object "System.Data.DataTable"

# Open the text file from disk
$reader = New-Object System.IO.StreamReader($csvfile)
$line = $reader.ReadLine()
$columns = $line.Split($csvdelimiter)

if ($firstrowcolumnnames -eq $false) {
  foreach ($column in $columns) {
    $null = $datatable.Columns.Add()
  }
  # start reader over
  $reader.DiscardBufferedData();
  $reader.BaseStream.Position = 0;
}
else {
  foreach ($column in $columns) {
    $null = $datatable.Columns.Add($column)
  }
}

# Read in the data, line by line
while ($ull -ne ($line = $reader.ReadLine())) {
  $row = $datatable.NewRow()
  $row.itemarray = $line.Split($csvdelimiter)
  $datatable.Rows.Add($row)

  # Once you reach your batch size, write to the db,
  # then clear the datatable from memory
  $i++;

  if (($i % $batchsize) -eq 0) {
    $bulkcopy.WriteToServer($datatable)
    Write-Output "$i rows have been inserted in $($elapsed.Elapsed.ToString()).";
    $datatable.Clear()
  }
}

# Close the CSV file
$reader.Close()

# Add in all the remaining rows since the last clear
if ($datatable.Rows.Count -gt 0) {
  $bulkcopy.WriteToServer($datatable)
  $datatable.Clear()
}

# Sometimes the Garbage Collector takes too long.
[System.GC]::Collect()

Write-Output "Script complete. $i rows have been inserted into the database."
Write-Output "Total Elapsed Time: $($elapsed.Elapsed.ToString())"
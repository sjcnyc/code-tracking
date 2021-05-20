function Get-ConnectionStatus {
  [CmdletBinding()]
  param
  (
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]
    $ComputerName
  )

  Process {
    ## New Process block
    foreach ($c in $ComputerName) {
      $status = (Test-Connection -ComputerName $c -Quiet -Count 1) ? 'OK' : 'No Connection'

      [pscustomobject]@{
        ComputerName = $c
        Status       = $status
      }
    }
  } ## end Process block
}


$thing = Invoke-WebRequest "https://docs.microsoft.com/en-us/azure/active-directory/hybrid/reference-connect-version-history" -UseBasicParsing
switch -Regex ($thing.Content -split '\n'){
    '>(\d+.\d+.\d+.\d+)</h2' {
        $param = @{ version = $Matches.1}
    }
    '<p>(?<date>\d{1,2}/\d{1,2}/\d*): (?<info>[^<]+)' {
        $param['date'] = $Matches.date
        $param['info'] = $Matches.info
        [pscustomobject]$param
    }
}

$result = Invoke-WebRequest "https://docs.microsoft.com/en-us/azure/active-directory/hybrid/reference-connect-version-history" -UseBasicParsing

switch -Regex ($result -split '(?=<h2)' | Out-String -Stream) {
  '<h2.+?>(.+?)</h2>' {
    $version = $Matches.1
  }
  '<p>(\d*/\d*/\d*):' {
    [PSCustomObject]@{
      Version = $Version
      Date    = $Matches.1
    }
  }
}

# Simulate Import-Csv
$mthcnt = @"
Workout,date,score,maxstreak
Workout1,04/05/21,653215,653
Workout2,04/05/21,25398,432
Workout1,05/05/21,325175,625
Workout1,06/05/21,65231,211
Workout1,07/05/21,86532,232
"@ | ConvertFrom-Csv

# loop through the CSV and create custom objects. Why? When imported from a CSV they're already objects with the properties you dictate with your CSV header
$Results = ForEach ($item in $mthcnt) {
  # building PSCustomObject
  [PsCustomObject]@{
    workout   = $item.workout
    date      = $item.date
    score     = $item.score
    maxstreak = $item.maxstreak
  }
}

# use Group-Object to find out how many instances of each workou there are
$workouts = $Results | Group-Object -Property workout

# Loop through your grouped workouts and produce new results that only include the workout name, recurrence count, and maxstreak average.
$Results2 = for ($i = 0; $i -lt $workouts.count; $i++) {
  [pscustomobject]@{
    Workout      = $workouts[$i].name
    WorkoutCount = $workouts[$i].Count
    MaxStreakAvg = ($workouts[$i].group.maxstreak | Measure-Object -Average).Average
  }
}


$Results2
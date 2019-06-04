#Requires -Version 3.0 
<# 
    .SYNOPSIS

    .DESCRIPTION 
 
    .NOTES 
        File Name  : Show-ElapsedTime
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/3/2014

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

#>

$Time = [System.Diagnostics.Stopwatch]::StartNew()
while ($true) {
  $CurrentTime = $Time.Elapsed
  write-host $([string]::Format("`rTime: {0:d2}:{1:d2}:{2:d2}",
      $CurrentTime.hours,
      $CurrentTime.minutes,
      $CurrentTime.seconds)) -NoNewline | Out-Null

  Start-Sleep 1 | out-null; Clear-Host
}

Import-Module PoShLog
New-Logger | Set-MinimumLevel -Value Verbose | Add-SinkConsole | Add-SinkFile -Path 'C:\Temp\my_awesome.log' | Start-Logger

# Test all log levels
Write-VerboseLog 'Test verbose message'
Write-DebugLog 'Test debug message'
Write-InfoLog 'Test info message'
Write-WarningLog 'Test warning message'
Write-ErrorLog 'Test error message'
Write-FatalLog 'Test fatal message'

# Example of formatted output
$position = @{
  Latitude  = 25
  Longitude = 134
}
$elapsedMs = 34

Write-InfoLog 'Processed {@Position} in {Elapsed:000} ms.' -PropertyValues $position, $elapsedMs

Close-Logger
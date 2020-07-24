[CmdletBinding(SupportsShouldProcess)]
Param([int]$minutes = 30)

## Create an Timer instance
$timer = New-Object Timers.Timer
## Now setup the Timer instance to fire events
$timer.Interval = 1000 * 60 * $minutes
$timer.AutoReset = $false  # do not enable the event again after its been fired
$timer.Enabled = $true
## register your event
## $args[0] Timer object
## $args[1] Elapsed event properties
Register-ObjectEvent -InputObject $timer -EventName Elapsed -SourceIdentifier powershell -Action {.\Get-MigrationReports.ps1}
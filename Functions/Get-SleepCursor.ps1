function Get-SleepCursor {
  <#
.SYNOPSIS
Animated sleep
.DESCRIPTION
Takes the title and displays a looping animation for a given number of seconds.
The animation will delete itself once it's finished, to save on console scrolling.
.PARAMETER seconds
A number of seconds to sleep for
.PARAMETER title
Some words to put next to the thing
.EXAMPLE
sleepanim
Will display a small animation for 1 second

sleepanim 5
Will display a small animation for 5 seconds
 
sleepanim 10 "Waiting for domain sync"
Will display "Waiting for domain sync " and a small animation for 10 seconds
 
.INPUTS
seconds, title
.OUTPUTS
A little animation
.LINK
 
#>
  [CmdletBinding()]
  param
  (
    [Parameter(Position = 1)][int]$seconds = 1,
    [Parameter(Position = 2)][string]$title = ''
  )
  $blank = "`b" * ($title.length + 2)
  $clear = ' ' * ($title.length + 2)
  $anim = @('\', '|', '/', '─', '\', '|', '/', '─') # Animation sequence characters
  while ($seconds -gt 0) {
    $anim |
      ForEach-Object {
      Write-Host "$blank$title $_" -NoNewline -ForegroundColor Yellow
      Start-Sleep -m 100
    }
    $seconds --
  }
  Write-Host "$blank$clear$blank" -NoNewline
}

Get-SleepCursor 10
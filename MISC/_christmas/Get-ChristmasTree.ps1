clear-host
write-host
$Rows = 30
$colors = "DarkRed", "Cyan", "Red", "Magenta", "Yellow", "White", "cyan"
$oldpos = $host.ui.RawUI.CursorPosition

Foreach ($r in ($rows..1)) {
  write-host $(" " * $r) -NoNewline
  1..((($rows - $r) * 2) + 1) | ForEach-Object {
    write-Host "*" -ForegroundColor Darkgreen  -nonewline
  }
  write-host ""
}

write-host $("{0}***" -f (‘ ‘ * ($Rows - 1) ))  -ForegroundColor DarkGreen
write-host $("{0}***" -f (‘ ‘ * ($Rows - 1) ))  -ForegroundColor DarkGreen
$host.ui.RawUI.CursorPosition = $oldpos
Start-Sleep .05
$numberstars = [math]::pow($Rows, 2)
$numberlights = $numberstars * .25

for ($i = 0; $i -lt $numberlights; $i++) {
  $Starlocation += @($host.ui.Rawui.CursorPosition)
}

$oldpos = $host.ui.RawUI.CursorPosition

while ($true) {
  foreach ($light in ($numberlights..1)) {
    $row = (get-random -min 1 -max (($Rows) + 1))
    $column = ($Rows - $row) + (get-random -min 1 -max ($row * 2))
    $temppos = $host.ui.rawui.CursorPosition
    $temppos.x = $column
    $temppos.y = $row
    $Starlocation[(($light) - 1)] = $temppos
    $host.ui.RawUi.CursorPosition = $temppoS
    write-Host "*" -ForegroundColor  ($colors | get-random) -nonewline
  }
  write-host ""
  Start-Sleep .5

  foreach ($light in ($numberlights..1)) {
    $host.ui.RawUI.CursorPosition = $Starlocation[(($light) - 1)]
    write-Host "*" -ForegroundColor DarkGreen -nonewline
  }
}
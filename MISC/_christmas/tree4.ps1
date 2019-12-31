#Clear the Screen

clear-host

#Move it all down the line

write-host

# Number of rows Deep for the Tree- from 2 to whatever fits on the screen, after 30 it gets funky

$Rows = 30

# Standard console Colours

$colors = "DarkRed", "Cyan", "Red", "Magenta", "Yellow", "White", "cyan"

# Get where the Cursor was

$oldpos = $host.ui.RawUI.CursorPosition
# BsponPosh’s ORIGINAL Tree building Algorithm 🙂
# None of this would be possible if it weren’t for him

Foreach ($r in ($rows..1)) {
  write-host $(" " * $r) -NoNewline
  1..((($rows - $r) * 2) + 1) | % {

    write-Host "*" -ForegroundColor Darkgreen  -nonewline

  }
  write-host ""
}

# trunk

write-host $("{0}***" -f (‘ ‘ * ($Rows - 1) ))  -ForegroundColor DarkGreen
write-host $("{0}***" -f (‘ ‘ * ($Rows - 1) ))  -ForegroundColor DarkGreen
$host.ui.RawUI.CursorPosition = $oldpos
sleep .05

# New Addins by Sean “The Energized Tech” Kearney

# Compute the possible number of stars in tree (Number of Rows Squared)

$numberstars = [math]::pow($Rows, 2)

# Number of lights to give to tree.  %25 percent of the number of green stars.  You pick

$numberlights = $numberstars * .25

# Initialize an array to remember all the “Star Locations”

for ($i = 0; $i -lt $numberlights; $i++) {
  $Starlocation += @($host.ui.Rawui.CursorPosition)
}

# Probably redundant, but just in case, remember where the  heck I am!

$oldpos = $host.ui.RawUI.CursorPosition

# Repeat this OVER and OVER and OVER and OVER

while ($true)
{

  foreach ($light in ($numberlights..1)) {
    # Pick a Random Row

    $row = (get-random -min 1 -max (($Rows) + 1))

    # Pick a Random Column – Note The Column Position is
    # Relative to the Row vs Number of Rows

    $column = ($Rows - $row) + (get-random -min 1 -max ($row * 2))

    #Grab the current position and store that away in a $Temp Variable
    $temppos = $host.ui.rawui.CursorPosition
    # Now Build new location of X,Y into $HOST
    $temppos.x = $column
    $temppos.y = $row

    # Store this away for later
    $Starlocation[(($light) - 1)] = $temppos

    # Now update that “STAR” with a Colour
    $host.ui.RawUi.CursorPosition = $temppoS
    write-Host "*" -ForegroundColor  ($colors | get-random) -nonewline
  }
  write-host ""

  #Sleep for half a sec
  Sleep .5

  # Now we just pull all those stars up and blank em back
  # with Green

  foreach ($light in ($numberlights..1)) {
    $host.ui.RawUI.CursorPosition = $Starlocation[(($light) - 1)]
    write-Host "*" -ForegroundColor DarkGreen -nonewline
  }

  # End of the loop, keep doin’ in and go “loopy!”

}
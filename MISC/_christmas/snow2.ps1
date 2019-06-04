$SnowMan = @"
.qggL     .gggr.
  PMML  . /|MM
  |!MM,' / |MM  .d/"q,  qgg;+Ml qgg;+Ml vgg. .y.
  | YMM,j' |MM  MM;.jMl |MM  "  |MM  "   qM| j"
  |  qM#'  |MM  MM|     |MM  +  |MM    .  MMg'
.j|.  qF  .+MM..'MMbxr' jMM.    jMM.  *   'MF
 .   *                                  x, /
  .x/--\xxl ,xx     .   *     ,gb       v#' .
.dMT    'q| |MM  '            '"'         .dM
dMM  *      |MM/dMg,  qgg;+Ml qgg  j/"'+  qMM-. qgg/dM#,w#Mb  ,g''fg, j/"'+
MMM    .'   |MM  MM|  |MM  "  |MM  MMbx/  |MM   |MM  |M|  MM  'p'. M| MMbx/
'MMl  +   . |MM  MM|  |MM  .  |MM  .'vMMl |MM   |MM  |M|  MM  , ,!. | .'vMMl
 'vMb...r/' jMM..MM|. jMM.  + jMM. +,.,P' 'MMx: jMM..dM|..MM, M j't | +,.,P'
                            _
                         __{_}_
                       .'______'-.
                     _:-'      `'-:
                _   /   _______    `\         And Happy Holidays!!!
             .-' \  \.-'       `'--./
           .'  \  \ /  () __ ()    \
           \ \\\#  ||    (__)      |
            \  #\\_||   '.___.'     |
             \___|\  \_________.--./
                  \\ |         \   \--.
                   \\/_________/   /   `\       ,
                   .\\        /`--;`-.   `-.__.'/
                  / _\\   ,_.'   _/ \ \        /
                 |    `\   \   /`    | '.___.-'
                  \____/\   '--\____/
                 /      \\           \
                |        \\           |
                |         \\          |
                |          \\         |
                \           \\        /
                 '.___..-.__.\\__.__.'     -Sean
"@

function Get-CharFromConsolePosition {
# function to get the character of a position in the console buffer
    param(
        [int]$X,
        [int]$Y
    )
      $r = New-Object System.Management.Automation.Host.Rectangle $x,$y,$x,$y
      $host.UI.RawUI.GetBufferContents($r)[0,0]
}

Clear-Host

$WinSize = $Host.UI.RawUI.WindowSize
$BGColor = $Host.UI.RawUI.BackgroundColor  
$CurrPos = $Host.UI.RawUI.CursorPosition 
 
If ($Host.UI.RawUI.CursorPosition.Y -gt $Host.UI.RawUI.WindowSize.Height) 
{ 
    $Top = $CurrPos.Y - $Host.UI.RawUI.WindowSize.Height + 1 
    $Bottom = $CurrPos.Y 
} else { 
    $Top = 1 
    $Bottom = $WinSize.Height 
} 
 
$MaxFlakes = 25 
 
$ColumnCount = $WinSize.Width 
 
$Columns = @{} 
 
0..$ColumnCount | ForEach-Object { $Columns.Add($_,$Bottom)}  
 
$Flakes = @{} 
$FlakeCount = 0 
 
#Clear-Host 
 
While($True) 
{ 
    If ($Host.UI.RawUI.KeyAvailable) { break } 
     
    If ((Get-Random $True,$False) -and ($Flakes.Count -lt $MaxFlakes)) 
    { 
        ++$FlakeCount 
        $Flakes.Add($FlakeCount,@((Get-Random -min 0 -max $ColumnCount),$Top)) 
    } 
    $Remove = @() 
       ForEach ($Flake in $Flakes.Keys)
    {
        # Prevent overwrite of non snowflakes on this position
        If((Get-CharFromConsolePosition $Flakes.$Flake.X  $Flakes.$Flake.Y).Character -eq '*') {

            # overwrite (delete) snowflake with background color
            $host.UI.RawUI.ForegroundColor = $BGColor
            $Host.UI.RawUI.CursorPosition = @{
              x=$Flakes.$Flake.X
              y=$Flakes.$Flake.Y
            }
            Write-Host '*' -NoNewline
            Start-Sleep -Milliseconds 1
        }

        # add row to shift the snowflake one row down
        $Flakes.$Flake.Y += 1

        # Set new position and color for snowflake
        $host.UI.RawUI.ForegroundColor = 'white'
        $Host.UI.RawUI.CursorPosition = @{
          x=$Flakes.$Flake.X
          y=$Flakes.$Flake.Y
        }
        # Prevent overwrite of non snowflakes
        $CurrChar = (Get-CharFromConsolePosition $Flakes.$Flake.X  $Flakes.$Flake.Y).Character
        If((($CurrChar -eq '*') -or ($CurrChar -eq '') -or ($CurrChar -eq ' '))) {
            # Draw snowflake on new position
            Write-Host '*' -NoNewline
        }

        # calculate the botom row to keep the snowflakes on the ground
        If ($Flakes.$Flake.Y -ge ($Columns.($Flakes.$Flake.X)-1))
        {
            --$Columns.($Flakes.$Flake.X)
            $Remove += $Flake
        }
    }

     # remove snowflakes from Hashtable that reached the bottom
     # so they will stay as a snow cover
     ForEach ($Item in $Remove)
     {
         $Flakes.Remove($Item)
     }
}

# set cursor
$Host.UI.RawUI.CursorPosition = @{
          x=$CurrPos.X
          y=$CurrPos.Y
        }
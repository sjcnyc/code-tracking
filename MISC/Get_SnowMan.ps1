function Get-CharFromConsolePosition {
# funktion to get the character of a position in the console buffer
    param(
        [int]$X,
        [int]$Y
    )
      $r = New-Object System.Management.Automation.Host.Rectangle $x,$y,$x,$y
      $host.UI.RawUI.GetBufferContents($r)[0,0]
}
 
$SnowMan = @"
                            _
                         __{_}_
                       .'______'-.
                     _:-'      `'-:
                _   /   _______    `\
             .-' \  \.-'       `'--./
           .'  \  \ /  () ___ ()    \
           \ \\\#  ||    (___)      |
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
                 '.___..-.__.\\__.__.'
"@
 
Clear-Host
 
# Set position to the bottom of the window to draw the Snowman
$Host.UI.RawUI.CursorPosition = @{  
    x=0 
    y=$Host.UI.RawUI.WindowSize.Height
}
 
# Draw  Snowman
$SnowMan
 
# Calculate console Window stuff
$WinSize = $Host.UI.RawUI.WindowSize 
$BGColor = $Host.UI.RawUI.BackgroundColor  
$CurrPos = $Host.UI.RawUI.CursorPosition 
 
# Calculate Bottom and Top Row 
If ($Host.UI.RawUI.CursorPosition.Y -gt $Host.UI.RawUI.WindowSize.Height) 
{ 
    $Top = $CurrPos.Y - $Host.UI.RawUI.WindowSize.Height + 1 
    $Bottom = $CurrPos.Y 
} else { 
    $Top = 1 
    $Bottom = $WinSize.Height 
}
 
# Set maximum of Snowflakes to Show 
$MaxFlakes = 25
 
# Set the amount of colums to draw to 
$ColumnCount = $WinSize.Width
 
# create empty hashtable to hold the columns 
$Columns = @{}
 
# Create column coordinates foreach column 
0..$ColumnCount | ForEach-Object { $Columns.Add($_,$Bottom)}  
 
# Empty hashtable to hold each snowflake
$Flakes = @{}
# Startnumber for the unique number used as snowflake key in the $Flakes hash
$FlakeCount = 0 
 
# endless loop to let it snow 
While($True) 
{ 
    # leave endless loop on any keypress
    If ($Host.UI.RawUI.KeyAvailable) { break } 
     
    # Add new flakes randomly distributed on the top row to 
    If ((Get-Random $True,$False) -and ($Flakes.Count -lt $MaxFlakes)) 
    { 
        # generate unique number used as key for a snowflake in the $Flakes hash
        ++$FlakeCount
        # Add snowflake to hashtable each Snowflake gets an Hashtable with its X,Y coordinates
        # X is th random column number of the SnowFlake and Y is the top Row to start folling down    
        $Flakes.Add($FlakeCount,@{X=(Get-Random -min 0 -max $ColumnCount);Y=$Top})  
    }
     
    # Create empty Array to hold the Snowflake numbers to remove from the $Flakes hashtable later
    $Remove = @()
    
    # Process each snowflake in the $Flakes Hashtable
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
            Write-Host "*" -NoNewline 
            Start-Sleep -Milliseconds 1
        }     
        
        # add row to shift the snowflake one row down
        $Flakes.$Flake.Y += 1
 
        # Set new position and color for snowflake 
        $host.UI.RawUI.ForegroundColor = "white"  
        $Host.UI.RawUI.CursorPosition = @{  
          x=$Flakes.$Flake.X 
          y=$Flakes.$Flake.Y 
        }  
        # Prevent overwrite of non snowflakes
        $CurrChar = (Get-CharFromConsolePosition $Flakes.$Flake.X  $Flakes.$Flake.Y).Character
        If((($CurrChar -eq '*') -or ($CurrChar -eq '') -or ($CurrChar -eq ' '))) {
            # Draw snowflake on new position 
            Write-Host "*" -NoNewline 
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
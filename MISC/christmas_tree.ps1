$Rows = 15
$colors = 'DarkRed','Cyan','Red','Magenta','Yellow','White','cyan' 
$hexdata='48:61:70:70:79:20:48:6f:6c:69:64:61:79:73:20:41:6c:65:78:21:21:20:20:53:65:65:20:79:6f:75:20:69:6e:20:74:68:65:20:4e:65:77:20:59:65:61:72:20:3a:29'           

while($true)
{
    $oldpos = $host.ui.RawUI.CursorPosition
    Foreach ($r in ($rows..1)){
        write-host $(' ' * $r) -NoNewline
        1..((($rows -$r) * 2)+1) | %{
            if (($_%2) -eq 0) {
                write-Host '*' -ForegroundColor Darkgreen  -nonewline
            } else {
                write-Host '*' -ForegroundColor  ($colors | get-random) -nonewline
            }
       }
        write-host ''
    } 
              
    write-host $('{0}***' -f (' ' * ($Rows -1) ))  -ForegroundColor DarkGreen
    write-host $('{0}***' -f (' ' * ($Rows -1) ))  -ForegroundColor DarkGreen
    $host.ui.RawUI.CursorPosition = $oldpos
    $hexdata.Split(':') | ForEach-Object {write-host –object ( [CHAR][BYTE]([CONVERT]::toint16($_,16))) –nonewline }
    break
    }


Clear-Host;
$Rows = 15
$colors = 'DarkRed','Cyan','Red','Magenta','Yellow','White','cyan' 
$hexdata='20:20:20:20:20:20:48:61:70:70:79:20:48:6f:6c:69:64:61:79:73:20:41:6e:64:72:65:77:21:21:20'           

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
  $hexdata.Split(':') | % {write-host –object ( [CHAR][BYTE]([CONVERT]::toint16($_,16))) –nonewline }
  break
}
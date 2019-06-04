function Print-TextToConsle([array]$text,[int]$delay) {
    Clear-Host
    do {
        $text = $text -split''
        $running = $true
        $text | ForEach-Object { Write-Host -Object $_ -NoNewline -ForegroundColor Green
            Start-Sleep -Milliseconds 100
            $running = $false
            }
       }
    while ($running)
  Start-Sleep -Seconds 5
  # Clear-Host
}

  Print-TextToConsle -text "IT WOULDN'T BE CHRISTMAS WITHOUT A POSH CHRISTMAS TREE!! :)" -delay 100
  #& '.\_New Projects\Files 2012\music.ps1'
  Clear-Host
  write-host ''
  Write-Host ''
  $starchar=[char][byte]15, '*'
  $Rows = 30
  $BottomRow=$Rows+4
  $BottomColumn=0
  $BottomMaxCol=($Rows)
  $Direction=1
  $colors = 'DarkRed','DarkBlue','DarkCyan','DarkMagenta','DarkYellow','Gray','DarkGray','Blue','Green','Cyan','Red','Magenta','Yellow','White'
  $oldpos = $host.ui.RawUI.CursorPosition

    Foreach ($r in ($rows..1)){
        write-host $(' ' * $r) -NoNewline
        1..((($rows -$r) * 2)+1) | ForEach-Object {
                write-Host '*' -ForegroundColor Darkgreen  -nonewline
       }
        write-host ''
    }

    write-host $('{0}***' -f (' ' * ($Rows -1) ))  -ForegroundColor DarkRed
    write-host $('{0}***' -f (' ' * ($Rows -1) ))  -ForegroundColor DarkRed
    write-host $('{0}***' -f (' ' * ($Rows -1) ))  -ForegroundColor DarkRed

  $host.ui.RawUI.CursorPosition = $oldpos
  $numberstars=[math]::pow($Rows,2)

  $numberlights=$numberstars *.35
  for ($i = 0; $i -lt $numberlights; $i++)
  {
    $Starlocation+=@($host.ui.Rawui.CursorPosition)
  }

  $oldpos = $host.ui.RawUI.CursorPosition

  foreach ($light in ($numberlights..1))
    {
    $row=(get-random -min 1 -max (($Rows)+1))
    $column=($Rows-$row)+(get-random -min 1 -max ($row*2))
    $temppos=$host.ui.rawui.CursorPosition
    $temppos.x=$column
    $temppos.y=$row
    $Starlocation[(($light)-1)]=$temppos
    }
  while($true)
  {
    for ($light=1; $light -lt 7; $light++)
    {
      $host.ui.RawUI.CursorPosition=($Starlocation | get-random)
      $flip=get-random -min 1 -max 1000
      if ($flip -gt 500)
        {
        write-Host ($starchar | get-random) -ForegroundColor  ($colors | get-random) -nonewline
      }
      else
      {
        write-host '*' -Foregroundcolor DarkGreen -nonewline
      }
    }

    $temppos=$oldpos
    $oldpos.X=$BottomColumn
    $oldpos.Y=$BottomRow
    $host.ui.Rawui.CursorPosition=$oldpos
    $BottomColumn=$BottomColumn+$Direction

    If ($BottomColumn -gt $Rows)
    { $Direction=-1 }

    If ($BottomColumn -lt 1)
    { $Direction=1 }

    write-host '   Happy Holidays Everyone!! ' -ForegroundColor  ($colors | get-random)
  }
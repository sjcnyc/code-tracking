$anim = @("|", "/", "-", "\", "|")
[Console]::SetBufferSize(512, 512)
while ($true) {

  $anim |
  ForEach-Object {
    write-host "`r$_" -NoNewline -ForegroundColor Yellow
    start-sleep -m 75
  }
}
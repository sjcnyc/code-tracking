function Print-TextToConsle {
  param
  (
    [System.Array]
    $text,
    
    [System.Int32]
    $delay
  )
  
  Clear-Host   
  do {
    $text = $text -split''
    $running = $true
    $text | ForEach-Object { Write-Host -Object $_ -NoNewline -ForegroundColor Green
      Start-Sleep -Milliseconds $delay
      $running = $false
    }
  }
  while ($running)
  #	sleep -Seconds 5
  #    Clear-Host
}
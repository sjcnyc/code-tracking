function Send-TextToConsle {
   param
   ( [array]$text,
     [int]$delay
   ) 
    Clear-Host
    do {
        $text = $text -split''
        $running = $true
        $text | ForEach-Object { Write-Host -Object $_ -NoNewline -ForegroundColor Green

        if ($delay) {
            Start-Sleep -Milliseconds $delay
            }
            $running = $false
            }
       }
    while ($running)
    Clear-Host
}
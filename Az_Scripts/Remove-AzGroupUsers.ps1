$host.ui.RawUI.WindowTitle = "Idle Keepalive"

$myshell = New-Object -com "Wscript.Shell"

While($true) { 
    $i++
    Start-Sleep -Seconds 60
    $myshell.sendkeys("{F15}")
    Write-Output "Keepalive script has been running for $i minutes"
}
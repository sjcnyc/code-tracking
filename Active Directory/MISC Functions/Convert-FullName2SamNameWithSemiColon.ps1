$notfound = @()
$users =
@'
connealy, sean
'@ -split [environment]::NewLine

foreach ($user in $users) {
    $result = Get-QADUser -Identity $user -Service 'me.sonymusic.com'
    if (!($result)) {
        $notfound += $user
    }
    else {
        "$($result.SAMAccountName)"
    }
}

if ($notfound) {
    Write-Host -Object ''
    Write-Host -Object 'Users Not found in AD' -ForegroundColor Red

    $notfound
}
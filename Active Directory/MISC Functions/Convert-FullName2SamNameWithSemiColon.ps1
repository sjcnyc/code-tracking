$notfound = @()
$users =
@'
Reece Laycock
Debbie Thompson
Johan Linglof
Ivo Baetschmann
Simon Mueller
Joe Doerner
Corrado Filpa
Georges Ouaggini
Berry van Sandwijk
Krokan Erling
Soren Kristensen
William Rowe
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
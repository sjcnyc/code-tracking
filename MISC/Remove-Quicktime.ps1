$versions = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
    Get-ItemProperty |
        Where-Object {$_.DisplayName -match 'quicktime' } |
            Select-Object -Property DisplayName, UninstallString

ForEach ($version in $versions) {

    If ($version.UninstallString) {

        $uninst = $version.UninstallString
        $uninst = $uninst -replace '/I', '/x '
        Start-Process cmd -ArgumentList "/c $uninst /quiet /norestart" -NoNewWindow
    }
}
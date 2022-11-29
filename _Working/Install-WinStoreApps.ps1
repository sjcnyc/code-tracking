$regkey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\InboxApplications"
$apps = Get-ChildItem -Path $regkey
ForEach ($key in $apps) {
    Add-AppxPackage -DisableDevelopmentMode -Register (Get-ItemProperty -Path $key.PsPath).Path
}
$regkey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Applications"
$apps = Get-ChildItem -Path $regkey
ForEach ($key in $apps) {
    Add-AppxPackage -DisableDevelopmentMode -Register (Get-ItemProperty -Path $key.PsPath).Path
}


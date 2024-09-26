function Set-header {
    $lastTop = [Console]::CursorTop
    [System.Console]::SetCursorPosition(0, 0)
    Write-Host "Computer object removal tool"
    [System.Console]::SetCursorPosition(0, $lastTop)
}

function Remove-ADCompDupe {
    param (
        [string]$hostname
    )
    Clear-Host
    Set-header
    write-host ''
    $collection = 0..10
    $count = 0
    foreach ($item in $collection) {
        $count++
        $percentComplete = ($count / $collection.Count) * 100
        Write-InlineProgress -Activity "Removing: $($hostname)" -PercentComplete $percentComplete -ShowPercent:$false

        Start-Sleep -Milliseconds (Get-Random -Minimum 160 -Maximum 400)
    }
    try {
        $computer = Get-ADComputer $hostname -Properties Name, Name | Select-Object Name, Enabled
        write-host ''
        Write-Output "$($computer.Name) removed"
    }
    catch {

        Write-Host "Computer: $($hostname) not found"
        Write-Host ''
    }
}



Clear-Host
Set-header
Write-Host ''
$hostname = Read-Host "Enter computer hostname"
Clear-Host
set-header
Write-Host ''
$collection = 0..10
$count = 0
foreach ($item in $collection) {
    $count++
    $percentComplete = ($count / $collection.Count) * 100
    Write-InlineProgress -Activity "Validating: $($hostname)" -PercentComplete $percentComplete -ShowPercent:$false
    Start-Sleep -Milliseconds (Get-Random -Minimum 160 -Maximum 400)
}
try {
    $computer = Get-adComputer $hostname -Properties canonicalname | Select-Object CanonicalName
    set-header
    Write-Host ''
    Write-Host "$($hostname) found at: $($computer.CanonicalName -replace "me.sonymusic.com/", '')"
    Write-Host ''
    start-sleep -Seconds 4
    Clear-Host
}
catch {
    Write-Host "Computer: $($hostname) not found"
    Write-Host ''
}
set-header
Write-Host "Remove $($hostname) from:"
Write-Host ""
$result = Show-Menu @("Active Directory", "SCCM collection", "Both")  -ReturnIndex

switch ($result) {
    0 {
        Remove-ADCompDupe -hostname $hostname
    }1 {
        Remove-SCCMCompDupe -hostname $hostname
    }2 {
        Remove-ADCompDupe -hostname $hostname
        Remove-SCCMCompDupe -hostname $hostname
    }
}
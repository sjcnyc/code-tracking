function Remove-ADCompDupe {
    param (
        [string]$hostname
    )
    Clear-Host
    Write-Host ''

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
        Clear-Host
        Write-Host ''
        Write-Host ''
        Write-Output "$($computer.Name) removed"
    }
    catch {
        Write-Host ''
        Write-Host ''
        Write-Host "Computer: $($hostname) not found"
        Write-Host ''
    }
}


$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Description."
#$no      = New-Object System.Management.Automation.Host.ChoiceDescription "&No",     "Description."
$cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "Description."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $cancel)

Clear-Host
$hostname = Read-Host "Enter computer hostname"
Clear-Host
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
    Clear-Host
    Write-Host ''
    Write-Host ''
    Write-Host "$($hostname) found at: $($computer.CanonicalName -replace "me.sonymusic.com/", '')"
    Write-Host ''

    $message = "Remove: $($hostname) from AD?"
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)
    switch ($result) {
        0 {
            Remove-ADCompDupe -hostname $hostname
        }1 {
            Write-Host "Cancel"
        }
    }
}
catch {
    Write-Host ''
    Write-Host ''
    Write-Host "Computer: $($hostname) not found"
    Write-Host ''
}



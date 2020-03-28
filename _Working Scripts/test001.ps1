$process = Get-Process

foreach ($process in $process) {
    $process.Name
}

$PSObj = [PSCustomObject]@{
    Name = $process.Name
    description = $process.Description
}

$PSObj
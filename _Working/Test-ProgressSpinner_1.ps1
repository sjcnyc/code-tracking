. .\Show-ProgressSpinner.ps1

Write-Host "Testing Progress Spinner`n"

# Test a long-running operation
$result = Show-ProgressSpinner -Message "Running long operation" -ScriptBlock {
    Start-Sleep -Seconds 5
    "Operation completed successfully!"
}

Write-Host $result

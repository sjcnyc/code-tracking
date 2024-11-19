function Show-ProgressSpinner {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        
        [Parameter()]
        [string]$Message = "Processing..."
    )

    # Create a background job for the main work
    $job = Start-Job -ScriptBlock $ScriptBlock

    # Spinner characters
    $spinner = @('|', '/', '-', '\')
    $i = 0

    # Show spinner while job is running
    while ($job.State -eq 'Running') {
        $spinChar = $spinner[$i % $spinner.Length]
        Write-Host "`r$spinChar $Message" -NoNewline
        Start-Sleep -Milliseconds 100
        $i++
    }

    # Clear the spinner line
    Write-Host "`r$(' ' * ($Message.Length + 2))" -NoNewline
    Write-Host "`r" -NoNewline

    # Get the result and clean up
    $result = Receive-Job -Job $job
    Remove-Job -Job $job

    return $result
}

# Example usage:
<#
Show-ProgressSpinner -Message "Working..." -ScriptBlock {
    Start-Sleep -Seconds 5
    "Operation completed!"
}
#>

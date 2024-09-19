# LoggerExample.ps1
# Example script demonstrating the usage of the Logger class

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$loggerPath = Join-Path $scriptPath "Logger.ps1"

Write-Host "Current directory: $PWD"
Write-Host "Script path: $scriptPath"
Write-Host "Logger path: $loggerPath"

try {
    # Import the Logger class
    . $loggerPath

    # Check if Logger class is available
    if (-not ([System.Management.Automation.PSTypeName]'Logger').Type) {
        throw "Logger class not found after importing $loggerPath"
    }

    # Create a Logger instance with explicit arguments
    $logger = [Logger]::new("$PWD\log.txt", [LogLevel]::Info)

    # Log messages at different levels
    $logger.Info("This is an informational message")
    $logger.Warning("This is a warning message")
    $logger.Error("This is an error message")

    Write-Host "`nChanging minimum log level to Warning`n"

    # Create a new Logger instance with Warning as the minimum log level
    $loggerWarning = [Logger]::new("$PWD\log_warning.txt", [LogLevel]::Warning)

    # Log messages at different levels
    $loggerWarning.Info("This informational message won't be logged")
    $loggerWarning.Warning("This warning message will be logged")
    $loggerWarning.Error("This error message will be logged")

    Write-Host "`nScript execution completed. Check log.txt and log_warning.txt for results."
}
catch {
    Write-Host "An error occurred: $_"
    Write-Host "Error type: $($_.Exception.GetType().FullName)"
    Write-Host "Stack trace: $($_.ScriptStackTrace)"

    # Additional error information
    if ($Error.Count -gt 0) {
        Write-Host "Last error details:"
        $Error[0] | Format-List * -Force
    }
}
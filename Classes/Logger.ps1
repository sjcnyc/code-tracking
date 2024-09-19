# Logger.ps1
# A PowerShell logging module using classes

# Enum for log levels
enum LogLevel {
    Info = 1
    Warning = 2
    Error = 3
}

class Logger {
    [string]$LogFilePath
    [LogLevel]$MinimumLogLevel

    # Constructor
    Logger([string]$logFilePath = ".\log.txt", [LogLevel]$minimumLogLevel = [LogLevel]::Info) {
        $this.LogFilePath = $logFilePath
        $this.MinimumLogLevel = $minimumLogLevel
    }

    # Private method to write log entry
    hidden [void] WriteLogEntry([LogLevel]$level, [string]$message) {
        if ($level.value__ -ge $this.MinimumLogLevel.value__) {
            $logEntry = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $level, $message
            Add-Content -Path $this.LogFilePath -Value $logEntry
            Write-Host $logEntry
        }
    }

    # Public methods for different log levels
    [void] Info([string]$message) {
        $this.WriteLogEntry([LogLevel]::Info, $message)
    }

    [void] Warning([string]$message) {
        $this.WriteLogEntry([LogLevel]::Warning, $message)
    }

    [void] Error([string]$message) {
        $this.WriteLogEntry([LogLevel]::Error, $message)
    }
}

# Example usage:
# $logger = [Logger]::new("C:\Logs\myapp.log", [LogLevel]::Warning)
# $logger.Info("This is an informational message")
# $logger.Warning("This is a warning message")
# $logger.Error("This is an error message")
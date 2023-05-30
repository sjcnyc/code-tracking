function Write-LogNew {
       param (
              [string[]]
              $Message,

              [string]
              $LogFile = $Script:LogFile,

              [switch]
              $ConsoleOutput,

              [ValidateSet("SUCCESS", "INFO", "WARN", "ERROR", "DEBUG")]
              [string]
              $LogLevel
       )
       $Message = $Message + $Input
       if (!$LogLevel) { $LogLevel = "INFO" }
       switch ($LogLevel) {
              SUCCESS { $Color = "Green" }
              INFO { $Color = "White" }
              WARN { $Color = "Yellow" }
              ERROR { $Color = "Red" }
              DEBUG { $Color = "Gray" }
       }
       if ($unll -ne $Message -and $Message.Length -gt 0) {
              $TimeStamp = [System.DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
              if ($LogFile -ne $null -and $LogFile -ne [System.String]::Empty) {
                     Out-File -Append -FilePath $LogFile -InputObject "[$TimeStamp] [$LogLevel] $Message"
              }
              if ($ConsoleOutput -eq $true) {
                     Write-Host "[$TimeStamp] [$LogLevel] :: $Message" -ForegroundColor $Color

                     if ($AutomationPSConnection -or $AutomationPSCertificate) {
                            Write-Output "[$TimeStamp] [$LogLevel] :: $Message"
                     }
              }
              if ($LogLevel -eq "ERROR") {
                     Write-Error "[$TimeStamp] [$LogLevel] :: $Message"
              }
       }
}

Write-LogNew -Message "This is a test message" -LogLevel SUCCESS -ConsoleOutput

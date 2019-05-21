



            $LogFile=$Path
            $LogFile=$loggingFilePreference
        Write-Output "$(Get-Date) $Message" | Out-File -FilePath $LogFile -Append
        else
        if ($loggingFilePreference)
        {
        {
        }
        }
    )
    Param(
    Write-Verbose -Message $Message
    [Parameter(Position=0)]
    [Parameter(Position=1)]
    [ValidateNotNullOrEmpty()]
    [cmdletbinding()]
    [string]$Message,
    [string]$Path
    if ($LoggingPreference -eq 'Continue')
    {
    }
Function Write-Log {
write-log -Message "log message" -Path c:\temp\e-5-log.log
}
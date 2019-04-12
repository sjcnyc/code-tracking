Clear-Host;
$JOB = "$($env:COMPUTERNAME)"
$DEST = "some\folder"
$SHARES = @("test1", "test2", "test3")

$jobs = foreach ($SHARE in $shares) {
    Write-Host "Starting Robocopy Sync for: \\$($JOB)\$($SHARE)"
    Start-Job -Name "Copyjob $SHARE" -ArgumentList $JOB, $DEST, $SHARE -ScriptBlock {
        param($JOB, $DEST, $SHARE)

        $SOURCE = "\\$($JOB)\$($SHARE)"
        $DESTINATION = "\\$($DEST)\$($JOB)\$($SHARE)"
        $INCLUDEFILES = @("*.*")
        $WHAT = @("/COPYALL")
        $OPTIONS = @("/R:3", "/W:1", "/E", "/V", "/NP", "/FP", "/ZB")
        $DATESTAMP = get-date -uformat "%Y-%m%-%d"
        $DATESTAMPEXT = Get-Date -format "ddd MMM dd HH:mm:ss yyy"
        $LOGFILE = "\\$($JOB)\c$\$($JOB)_$($SHARE)-Robocopy-$($DATESTAMP).log"
        $ROBOCOPYLOG = "/LOG:$LOGFILE"
        $ROBOCOPYEXEC = "C:\Windows\System32\Robocopy.exe"

        $checkdir = Test-Path -PathType Container "\\$($DEST)\$($JOB)" | Out-Null
        if ($checkdir -eq $false) {
            New-Item "\\$($DEST)\$($JOB)" -type Directory | Out-Null
        }

        $cmdArgs = @("$SOURCE", "$DESTINATION", $INCLUDEFILES, $WHAT, $ROBOCOPYLOG, $OPTIONS)

        $LogMsg = ("-" * 79) + "`r`n$($DATESTAMPEXT) $(${JOB}): Starting robocopy"
        Add-content $LOGFILE $LogMsg -PassThru

        & $ROBOCOPYEXEC @cmdArgs | Tee-Object -Variable RoboLog

        $ExitCode = $LastExitCode

        $LogMsg = ("-" * 79) + "`r`n$(${SOURCE}): Robocopy finished with exit code: $($exitCode)`r`n"
        Add-content $LOGFILE $LogMsg -PassThru

        $MSGType = @{
            "16" = "Error"
            "15" = "Information"
            "14" = "Error"
            "13" = "Information"
            "12" = "Error"
            "11" = "Information"
            "10" = "Error"
            "9"  = "Inforamtion"
            "8"  = "Error"
            "7"  = "Information"
            "6"  = "Information"
            "5"  = "Information"
            "4"  = "Warning"
            "3"  = "Information"
            "2"  = "Information"
            "1"  = "Information"
            "0"  = "Information"
        }

        $MSG = @{
            "16" = "[ERRR] - Serious error. Robocopy did not copy any files.`r`nExamine the output log:`r`n$LOGFILE"
            "15" = "[INFO] - OKCOPY + FAIL + MISMATCHES + XTRA"
            "14" = "[INFO] - FAIL + MISMATCHES + XTRA"
            "13" = "[INFO] - OKCOPY + FAIL + MISMATCHES"
            "12" = "[INFO] - FAIL + MISMATCHES"
            "11" = "[INFO] - OKCOPY + FAIL + XTRA"
            "10" = "[INFO] - FAIL + XTRA"
            "9"  = "[INFO] - OKCOPY + FAIL"
            "8"  = "[ERRR] - Some files or directories could not be copied`r`nCopy errors occurred and the retry limit was exceeded.`r`nExamine the output log:`r`n$LOGFILE"
            "7"  = "[INFO] - OKCOPY + MISMATCHES + XTRA"
            "6"  = "[INFO] - MISMATCHES + XTRA"
            "5"  = "[INFO] - OKCOPY + MISMATCHES"
            "4"  = "[WARN] - Some Mismatched files or directories were detected.`r`nExamine the output log:`r`n$LOGFILE"
            "3"  = "[INFO] - OKCOPY + XTRA"
            "2"  = "[INFO] - Some Extra files or directories were detected.`r`nExamine the output log:`r`n$LOGFILE"
            "1"  = "[INFO] - One or more files were copied successfully (that is, new files have arrived)."
            "0"  = "[INFO] - No errors occurred, and no copying was done.`r`nThe source and destination directory trees are completely synchronized."
        }

        function Test-Administrator	{
            $user = [Security.Principal.WindowsIdentity]::GetCurrent();
            (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        }

        # If running with administrator privileges
        If (Test-Administrator -eq $True) {
            "Has administrator privileges"

            # Create EventLog Source if not already exists
            if ([System.Diagnostics.EventLog]::SourceExists("$JOB") -eq $false) {
                "Creating EventLog Source `"$JOB`""
                [System.Diagnostics.EventLog]::CreateEventSource("$JOB", "Application")
            }
        }

        if ($MSG."$ExitCode" -gt $null) {
            $StatusReport = $MSG."$exitCode"
            Write-EventLog -LogName Application -Source $JOB -EventID $ExitCode -EntryType $MSGType."$ExitCode" -Message $MSG."$ExitCode"
        }
        else {
            $StatusReport = "[Unknown] Can't interpret this exit code."
            Write-EventLog -LogName Application -Source $JOB -EventID $ExitCode -EntryType Warning -Message "Unknown ExitCode. EventID equals ExitCode"
        }

        $notifyCodes = @(16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)
        if ($notifyCodes -contains $exitCode) {
            $log1 = Get-Content $LOGFILE | out-string
            $pat1 = [regex]::match($log1, '(?<=\    Extras).+(?=)', "singleline").value

            $BODY = @"
$($SOURCE): Robocopy Sync Completed.

------------------------------------------------------------------------------

 Started : $($DATESTAMPEXT)

  Source : $($SOURCE)
    Dest : $($DESTINATION)

 Options : $($WHAT) $($OPTIONS)

 ------------------------------------------------------------------------------

               Total    Copied   Skipped  Mismatch    FAILED    Extras
$($pat1)
$($StatusReport)

Output log: $($LOGFILE)"
"@

            $smtpProps = @{
                smtpserver = 'ussmpt01.bmg.bagint.com'
                From       = 'Posh Alerts poshalerts@sonymusic.com'
                To         = 'sconneal@sonymusic.com'
                Subject    = "[Robocopy Sync: $($SOURCE)] Execution report"
                Body       = "$($BODY)"
            }

            Add-content $LOGFILE "$($DATESTAMPEXT) $($StatusReport)" -PassThru
            Send-MailMessage @smtpProps
        }
        # We're all done! Pass through dat exit code.
        Exit $exitCode
    }
}

$jobs | Wait-Job | out-null
$jobs | Receive-Job
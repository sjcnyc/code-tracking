Clear-Host;
$JOB = "$($env:COMPUTERNAME)"
$DEST = 'usstorage02\remotebackups'
$SHARES = @('test1', 'test2', 'test3')
$EMAILLOG = 'C:\temp\logs\email.log'
$JOBS = @()
$RESULTS = @()

foreach ($SHARE in $SHARES) {
  Write-Host "Starting Robocopy Synch for: \\$($JOB)\$($SHARE)"
  $jobs += Start-Job -Name "Copyjob $SHARE" -ArgumentList $JOB, $DEST, $SHARE -ScriptBlock {
    param($JOB, $DEST, $SHARE)
        
    $SOURCE = "\\$($JOB)\$($SHARE)"
    $DESTINATION = "\\$($DEST)\$($JOB)\$($SHARE)"
    $INCLUDEFILES = @('*.*')
    $WHAT = @('/COPYALL')
    $OPTIONS = @('/R:3', '/W:1', '/E', '/V', '/NP', '/FP', '/ZB')
    $DATESTAMP = get-date -uformat '%Y-%m%-%d'
    $DATESTAMPEXT = Get-Date -format 'ddd MMM dd HH:mm:ss yyy'
    $checkdir = Test-Path -PathType Container "\\$($DEST)\$($JOB)"

    if ($checkdir -eq $false) {
      New-Item "\\$($DEST)\$($JOB)" -type Directory | Out-Null
    }
        
    $checkLogDir = Test-Path -PathType Container "\\$($DEST)\Logs\$($JOB)\"

    if ($checkLogDir -eq $false) {
      New-Item -path "\\$($DEST)\Logs\$($JOB)\" -ItemType  Directory | Out-Null
    }

    $LOGFILE = "\\$($DEST)\Logs\$($JOB)\$($JOB)_$($SHARE)_$($DATESTAMP).log"
    $ROBOCOPYLOG = "/LOG:$LOGFILE"
    $ROBOCOPYEXEC = 'C:\Windows\System32\Robocopy.exe'
    
    $cmdArgs = @("$SOURCE", "$DESTINATION", $INCLUDEFILES, $WHAT, $ROBOCOPYLOG, $OPTIONS)
    
    $LogMsg = ('-' * 79) + "`r`n$($DATESTAMPEXT) $(${JOB}): Starting robocopy"
    Add-content $LOGFILE $LogMsg -PassThru | out-null
    
    & $ROBOCOPYEXEC @cmdArgs | out-null
    
    $ExitCode = $LastExitCode
    
    $LogMsg = ('-' * 79) + "`r`nSynch finished with exit code: $($exitCode)"
    Add-content $LOGFILE $LogMsg -PassThru | out-null
    
    $MSGType = @{
      '16' = 'Error'
      '15' = 'Information'
      '14' = 'Error'
      '13' = 'Information'
      '12' = 'Error'
      '11' = 'Information'
      '10' = 'Error'
      '9'  = 'Inforamtion'
      '8'  = 'Error'
      '7'  = 'Information'
      '6'  = 'Information'
      '5'  = 'Information'
      '4'  = 'Warning'
      '3'  = 'Information'
      '2'  = 'Information'
      '1'  = 'Information'
      '0'  = 'Information'
    }
    
    $MSG = @{
      '16' = "[ERRR] - Serious error. Robocopy did not copy any files.`r`n`nOutput Log: <a href='$LOGFILE'>$($JOB)_$($SHARE)_$($DATESTAMP).log</a>"
      '15' = '[INFO] - OKCOPY + FAIL + MISMATCHES + XTRA'
      '14' = '[INFO] - FAIL + MISMATCHES + XTRA'
      '13' = '[INFO] - OKCOPY + FAIL + MISMATCHES'
      '12' = '[INFO] - FAIL + MISMATCHES'
      '11' = '[INFO] - OKCOPY + FAIL + XTRA'
      '10' = '[INFO] - FAIL + XTRA'
      '9'  = '[INFO] - OKCOPY + FAIL'
      '8'  = "[ERRR] - Some files or directories could not be copied`r`nCopy errors occurred and the retry limit was exceeded.`r`n`nOutput Log: <a href='$LOGFILE'>$($JOB)_$($SHARE)_$($DATESTAMP).log</a>"
      '7'  = '[INFO] - OKCOPY + MISMATCHES + XTRA'
      '6'  = '[INFO] - MISMATCHES + XTRA'
      '5'  = '[INFO] - OKCOPY + MISMATCHES'
      '4'  = "[WARN] - Some Mismatched files or directories were detected.`r`n`nOutput Log: <a href='$LOGFILE'>$($JOB)_$($SHARE)_$($DATESTAMP).log</a>"
      '3'  = '[INFO] - OKCOPY + XTRA'
      '2'  = "[INFO] - Some Extra files or directories were detected.`r`n`nOutput Log: <a href='$LOGFILE'>$($JOB)_$($SHARE)_$($DATESTAMP).log</a>" 
      '1'  = "[INFO] - One or more files were copied successfully (that is, new files have arrived).`r`n`nOutput Log: <a href='$LOGFILE'>$($JOB)_$($SHARE)_$($DATESTAMP).log</a>"
      '0'  = "[INFO] - No errors occurred, and no copying was done.`r`nThe source and destination directory trees are completely synchronized.`r`n`nOutput Log: <a href='$LOGFILE'>$($JOB)_$($SHARE)_$($DATESTAMP).log</a>" 
    }
    
    function Test-Administrator	{  
      $user = [Security.Principal.WindowsIdentity]::GetCurrent();
      (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
    }
    
    # If running with administrator privileges
    If (Test-Administrator -eq $True) {
      'Has administrator privileges' | out-null
      
      # Create EventLog Source if not already exists
      if ([System.Diagnostics.EventLog]::SourceExists("$JOB") -eq $false) {
        "Creating EventLog Source `"$JOB`""
        [System.Diagnostics.EventLog]::CreateEventSource("$JOB", 'Application')
      }
    }
    
    if ($MSG."$ExitCode" -gt $null) {
      $StatusReport = $MSG."$exitCode"
      Write-EventLog -LogName Application -Source $JOB -EventID $ExitCode -EntryType $MSGType."$ExitCode" -Message "$($StatusReport)"
    } 
    else {
      $StatusReport = "[Unknown] Can't interpret this exit code."
      Write-EventLog -LogName Application -Source $JOB -EventID $ExitCode -EntryType Warning -Message 'Unknown ExitCode. EventID equals ExitCode'
    }
    
    $notifyCodes = @(16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)
    if ($notifyCodes -contains $exitCode) {
      $parseLog = Get-Content $LOGFILE | out-string 
      $pattern = [regex]::match($parseLog, '(?<=\    Extras).+(?=)', 'singleline').value

      # Email Body		
      $BODY = @"
------------------------------------------------------------------------------
<span style='color:blue;font-weight:bold;'>Share Folder: $($SHARE) Synch Completed.</span>
------------------------------------------------------------------------------
 Started : $($DATESTAMPEXT)

  Source : $($SOURCE)
    Dest : $($DESTINATION)
 
 Options : $($WHAT) $($OPTIONS)
------------------------------------------------------------------------------
 
               Total    Copied   Skipped  Mismatch    FAILED    Extras
$($pattern)
<span style='font-style:italic;'>$($StatusReport)</span>


"@
      write-output $BODY
      Add-content $LOGFILE "$($DATESTAMPEXT) $($StatusReport)" -PassThru | out-null
    }
    # Pass through the exit code.
    Exit $exitCode		
  }
}

$JOBS | Wait-Job | out-null
$RESULTS += $JOBS | Receive-Job

Out-File -InputObject $RESULTS -FilePath $EMAILLOG -Force | out-null

$EMAIL = @()

$EMAIL += "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>"
$EMAIL += '<html><head><title>Posh Report</title>'
$EMAIL += "<style type='text/css'>"
$EMAIL += '<!--'
$EMAIL += 'pre {font-family:fixed,courier new, courier, monospace;font-size:8pt;margin:0em;}'
$EMAIL += '-->'
$EMAIL += '</style></head>'
$EMAIL += '<body><pre>'
$EMAIL += "$(foreach ($line in (Get-Content -Path "$($emailLog)" -delimiter "`n")){"$($line)"})"
$EMAIL += '</pre></body></html>'

$smtpProps = @{
  smtpserver = 'ussmtp01.bmg.bagint.com'
  From       = 'poshalerts@sonymusic.com'
  To         = 'sconnea@sonymusic.com'
  Subject    = "[Robocopy Synch: $($JOB)] Execution report"
  Body       = "$($EMAIL)"
  BodyAsHtml = $true
}

Send-MailMessage @smtpProps
# We are all done kids!
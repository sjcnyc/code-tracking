#Requires -Version 2 
<# 
    .SYNOPSIS 
  
  
    .DESCRIPTION 
  
  
    .NOTES     : Start-Robocopy_Mactech
    File Name  : 
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 10/4/2014
  
    .LINK
    This script posted to: http://www.github/sjcnyc
  
    .EXAMPLE
  
    .EXAMPLE
  
#>

$SourceFolder = '\\storage\mactech$\Filevault-Keys'
$DestinationFolder = '\\storage\bitlocker$\MFV'
$DATESTAMP = Get-Date -UFormat '%Y-%m%-%d'
$DATESTAMPEXT = Get-Date -Format 'ddd MMM dd HH:mm:ss yyy'
$Logfile = 'C:\Robocopy.log'
$Subject = 'Mactech Copy - Filevault-Keys => MFV'
$SMTPServer = 'ussmtp01.bmg.bagint.com'
$Sender = 'poshalerts@sonymusic.com'
$Recipients = 'sconnea@sonymusic.com' #,'russell.irwin@sonymusic.com', 'Alex.Moldoveanu@sonymusic.com','juan.rivera.peak@sonymusic.com'
$SendEmail = $True
$IncludeAdmin = $True
$AsAttachment = $False

Robocopy.exe $SourceFolder $DestinationFolder /COPYALL /R:3 /W:1 /E /V /FP /ZB /XO /XX /FFT /LOG:$Logfile /NP /FP /NDL

#To remove all Lines with string "Extra File"
(Get-Content $Logfile) -replace '(.*Extra File).+' | Set-Content $Logfile

#To remove all empty lines 
(Get-Content $Logfile) |
    Where-Object -FilterScript {$_ -match '\S'} |
    Set-Content $Logfile 

$ExitCode = $LastExitCode

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
    '16' = '[ERRR] - Serious error. Robocopy did not copy any files.'
    '15' = '[INFO] - OKCOPY + FAIL + MISMATCHES + XTRA'
    '14' = '[INFO] - FAIL + MISMATCHES + XTRA'
    '13' = '[INFO] - OKCOPY + FAIL + MISMATCHES'
    '12' = '[INFO] - FAIL + MISMATCHES'
    '11' = '[INFO] - OKCOPY + FAIL + XTRA'
    '10' = '[INFO] - FAIL + XTRA'
    '9'  = '[INFO] - OKCOPY + FAIL'
    '8'  = "[ERRR] - Some files or directories could not be copied`r`nCopy errors occurred and the retry limit was exceeded."
    '7'  = '[INFO] - OKCOPY + MISMATCHES + XTRA'
    '6'  = '[INFO] - MISMATCHES + XTRA'
    '5'  = '[INFO] - OKCOPY + MISMATCHES'
    '4'  = '[WARN] - Some Mismatched files or directories were detected.'
    '3'  = '[INFO] - OKCOPY + XTRA'
    '2'  = '[INFO] - Some Extra files or directories were detected.'
    '1'  = "[INFO] - One or more files were copied successfully (that is, new files`r`n have arrived)."
    '0'  = "[INFO] - No errors occurred, and no copying was done.`r`nThe source and destination directory trees are completely synchronized."
}

$notifyCodes = @(16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)
$StatusReport = $MSG."$ExitCode"

# Modify the subject with Exit Reason and Exit Code
$Subject += ' : ' + $StatusReport + ' ExitCode: ' + $ExitCode

# Test log file size to determine if it should be emailed
# or just a status email

$Email = @()

$Email += "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>"
$Email += '<html><head><title>Posh Report</title>'
$Email += "<style type='text/css'>"
$Email += '<!--'
$Email += 'tr {font-family:Lucida Sans Unicode;font-size:8pt;margin:0em;background-color:#fff;}'
$Email += '-->'
$Email += '</style></head>'
$Email += '<body><table>'
$Email += "$(foreach ($line in (Get-Content -Path "$($Logfile)" -Delimiter "`n")){"<tr><td>$($line)</td></tr>"})"
$Email += '</table></body></html>'

$smtpProps = @{
    smtpserver = $SMTPServer
    From       = $Sender
    To         = $Recipients
    Subject    = "$($Subject)"
    Body       = "$($Email)"
    BodyAsHtml = $True
}

Send-MailMessage @smtpProps
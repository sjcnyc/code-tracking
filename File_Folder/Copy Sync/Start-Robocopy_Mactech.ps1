  #Requires -Version 3.0 
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
  
#*=============================================
#* Base variables
#*=============================================

$SourceFolder = '\\storage\mactech$\Filevault-Keys'
$DestinationFolder = '\\storage\bitlocker$\MFV'
$DATESTAMP = get-date -uformat '%Y-%m%-%d'
$DATESTAMPEXT = Get-Date -format 'ddd MMM dd HH:mm:ss yyy'
$Logfile = 'C:\Robocopy.log'
$Subject = 'Mactech Copy'
$SMTPServer = 'ussmtp01.bmg.bagint.com'
$Sender = 'Posh Alerts poshalerts@sonymusic.com'
$Recipients = 'sconnea@sonymusic.com' # ,'russell.irwin@sonymusic.com', 'Alex.Moldoveanu@sonymusic.com'
$SendEmail = $True
$IncludeAdmin = $True
$AsAttachment = $false

#*=============================================
#* SCRIPT BODY
#*=============================================

Robocopy $SourceFolder $DestinationFolder /COPYALL /R:3 /W:1 /E /V /FP /ZB /XO /XX /FFT /LOG:$Logfile /NP /FP /NDL


#To remove all Lines with string "Extra File"
 (Get-Content $Logfile)-replace '(.*Extra File).+' | Set-Content $Logfile
#To remove all lines with string "same"
 (Get-Content $Logfile)-replace '(.*same).+' | Set-Content $Logfile
#To remove all empty lines 
(Get-Content $Logfile) | Where-Object {$_ -match '\S'} | Set-Content $Logfile 

$ExitCode = $LastExitCode

		$MSGType=@{
			'16'='Error'
			'15'='Information'
			'14'='Error'
			'13'='Information'
			'12'='Error'
			'11'='Information'
			'10'='Error'
			'9'='Inforamtion'
			'8'='Error'
			'7'='Information'
			'6'='Information'
			'5'='Information'
			'4'='Warning'
			'3'='Information'
			'2'='Information'
			'1'='Information'
			'0'='Information'
		}
		
		$MSG=@{
			'16'='[ERRR] - Serious error. Robocopy did not copy any files.'
			'15'='[INFO] - OKCOPY + FAIL + MISMATCHES + XTRA'
			'14'='[INFO] - FAIL + MISMATCHES + XTRA'
			'13'='[INFO] - OKCOPY + FAIL + MISMATCHES'
			'12'='[INFO] - FAIL + MISMATCHES'
			'11'='[INFO] - OKCOPY + FAIL + XTRA'
			'10'='[INFO] - FAIL + XTRA'
			'9' ='[INFO] - OKCOPY + FAIL'
			'8' ="[ERRR] - Some files or directories could not be copied`r`nCopy errors occurred and the retry limit was exceeded."
			'7' ='[INFO] - OKCOPY + MISMATCHES + XTRA'
			'6' ='[INFO] - MISMATCHES + XTRA'
			'5' ='[INFO] - OKCOPY + MISMATCHES'
			'4' ='[WARN] - Some Mismatched files or directories were detected.'
			'3' ='[INFO] - OKCOPY + XTRA'
			'2' ='[INFO] - Some Extra files or directories were detected.' 
			'1' ="[INFO] - One or more files were copied successfully (that is, new files`r`n have arrived)."
			'0' ="[INFO] - No errors occurred, and no copying was done.`r`nThe source and destination directory trees are completely synchronized." 
		}

$notifyCodes = @(16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)
$StatusReport = $MSG."$exitCode"

# Modify the subject with Exit Reason and Exit Code
$Subject += ' : ' + $StatusReport + ' ExitCode: ' + $ExitCode

# Test log file size to determine if it should be emailed
# or just a status email

If ((Get-ChildItem $Logfile).Length -lt 256kb){
  
  Send-MailMessage -From $Sender -To $Recipients -Subject $Subject -Body (Get-Content $LogFile | Out-String) -SmtpServer $SMTPServer  
}
else {
  Send-MailMessage -From $Sender -To $Recipients -Subject $Subject -Body 'Robocopy results are attached.' -Attachment $Logfile -SmtpServer $SMTPServer
  
}

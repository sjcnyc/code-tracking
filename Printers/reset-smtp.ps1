#Variables needed by script
$printerserver = "print server address"
$smtpserver = "smtp server address"
$emailaddress = "email address to send as"
$smtplogin = "email login here"
$smtppassword = "email password here"
$printerlogin = "printer login here (usually 11111)"
$printerpassword = "printer password here (usually x-admin)"

#Connects to print server and selects all Fuji-Xerox printers
#You can also just make this an array of IP's
$printerips = (Get-Printer -ComputerName $printerserver | ?{$_.drivername -like "FX*"} | sort -Unique portname | ?{[bool]($_.portname -as [ipaddress])}).portname

Function Send-POST {
	Param(
		[parameter(Mandatory=$true)]
		[string]$URL,
		[parameter(Mandatory=$true)]
		[string]$Data
	)
	$buffer = [text.encoding]::ascii.getbytes($data)
	[net.httpWebRequest] $req = [net.webRequest]::create($url)
	$req.Credentials = New-Object System.Net.NetworkCredential($printerlogin,$printerpassword)
	$req.method = "POST"
	$req.ContentType = "application/x-www-form-urlencoded"
	$req.ContentLength = $buffer.length
	$req.KeepAlive = $true
	$reqst = $req.getRequestStream()
	$reqst.write($buffer, 0, $buffer.length)
	$reqst.flush()
	$reqst.close()
	try {
		[net.httpWebResponse] $res = $req.getResponse()
		$resst = $res.getResponseStream()
		$sr = new-object IO.StreamReader($resst)
		$result = $sr.ReadToEnd()
		$res.close()
		return $result;
	}
	catch {
		return "Server Unavailable"
	}
}

foreach ($printerip in $printerips) {
	$initping = Test-NetConnection -ComputerName $printerip
	if (($initping.PingSucceeded) -ne "True") {	Write-Warning "$printerip : Printer does not respond to ping - do you have the right IP?" }
	else {
		#Set SMTP Settings
		#SP0 and FSP0 have to match - these are the passwords. ESP0 refers to the password being changed
		#ATH=2 means use SMTP authentication. ATH=1 means POP before SMTP. ATH=0 means no authentication
		#UCRE=0 means use remotely authenticated user, UCRE=1 means use system. Used by older DocuCentre machines
		$x = Send-POST -URL "http://$printerip/SMTPMODE.cmd" -Data "SVTYPE=&DEFSPLIT=0&SAD=$smtpserver&SPN=25&SPNRECV=25&SMTPSSLTLS=0&WEA=$($emailaddress -replace '@','%40')&MAXMSG=10240&MAXJOB=20000&ATH=2&SU0=$($smtplogin -replace '@','%40')&SP0=$smtppassword&FSP0=$smtppassword&MAXFLG=1&ESP0=on&SRVCHK=0&MSGSPLT=0&RBTFLG=0&SPNDIFAX=25"
		if ($x -match "Server Unavailable") {
			Write-Output "$printerip : Machine has an older firmware, attempting method 2"
			$x = Send-POST -URL "http://$printerip/SMTPMODE.cmd" -Data "SAD=$smtpserver&SPN=25&SPNRECV=25&WEA=$($emailaddress -replace '@','%40')&MAXMSG=10240&MAXJOB=20000&ATH=2&SU0=$($smtplogin -replace '@','%40')&SP0=$smtppassword&FSP0=$smtppassword&MAXFLG=1&ESP0=on&SRVCHK=0&MSGSPLT=0&UCRE=0"
		}
		if ($x -match "Settings have been changed") {
			try {
				Write-Output "$printerip : SMTP settings changed on machine, attempting reboot"
				$x = Send-POST -URL "http://$printerip/DEVCTRL.cmd" -Data "OPR=REBOOT"
				if (!($x -match "Your request was successfully processed")) { Write-Warning "$printerip : Could not reboot machine, moving to next machine" }
				else {
					Write-Output "$printerip : Machine is rebooting, sleeping for 45 seconds"
					Start-Sleep -s 45
					$pingtest = Test-NetConnection -ComputerName $printerip
					if (($pingtest.PingSucceeded) -ne "True") {	Write-Warning "$printerip : Machine has not come back online after 45 seconds, please test" }
					else { Write-Output "$printerip : Machine has successfully updated its SMTP settings and rebooted" }
				}
			}
			catch {
				Write-Warning "$printerip : Failed - $($error[0].Exception)"
			}
		}
		else {
			Write-Warning "$printerip : Could not set SMTP settings on machine, moving to next machine"
			continue
		}
	}
}
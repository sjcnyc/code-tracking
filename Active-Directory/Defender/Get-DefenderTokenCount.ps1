# // Uncomment this to create secure password
#$secureString = Read-Host -AsSecureString
#ConvertFrom-SecureString $secureString | out-file c:\encrypted.txt
#$secure = gc C:\encrypted.txt | ConvertTo-SecureString

# // This is to clean up any old xml and html files from running reports
$reporthtml = 'C:\Program Files (x86)\Quest Software\Defender\Defender Report Console\downloads\html\*.html'
$reportxml = 'C:\Program Files (x86)\Quest Software\Defender\Defender Report Console\downloads\*.xml'
if (Test-Path $reporthtml)
{
Remove-item $reporthtml
}
if (Test-Path $reportxml)
{
Remove-item $reportxml
}

# // Change to reflect your servername
$url = 'http://nycsbmeads004/cgi-bin/d5dsslicensereport.exe?mode=0&xsl=d5licensereport.xsl&#8221'
# // create a request
[Net.HttpWebRequest] $req = [Net.WebRequest]::create($url)
$req.Method = 'GET'
$req.Timeout = 600000 # = 10 minutes

#  Set if you need a username/password to access the resource
$secure = Get-Content C:\encrypted.txt | ConvertTo-SecureString;
$UserName = 'domain\username';
$req.Credentials = New-Object System.Management.Automation.PSCredential($UserName, $secure);

#  Reading data from page
[Net.HttpWebResponse] $result = $req.GetResponse()
[IO.Stream] $stream = $result.GetResponseStream()
[IO.StreamReader] $reader = New-Object IO.StreamReader($stream)
[string] $output = $reader.readToEnd()
$stream.flush()
$stream.close()
$output | out-null
[xml]$defxml = $output
$final = $defxml.defender_license.desktop_license | Select-Object Type,Assigned,Allocation | ConvertTo-Html
function SendMail
{
#Mail Variables
$EmailFrom = 'who@ever.com>'
$EmailSubject = 'Daily Defender Token Count'
$smtpServer = 'relay'
$SendTo = 'you@yours.com'
$date = (Get-Date -format 'MM-dd-yyyy')

$mailmessage = New-Object system.net.mail.mailmessage

############## MAIL BODY #############

# Update body with any text you want and variables # #
######################################

$body = “
<lang=EN-US link=blue vlink=purple><div><p>
<span style=font-size:10.0pt;font-family:tahoma,sans-serif;color:#595959>
<dd><p><b>Defender Token count as of $date </b>
<p>
<p><pre style=font-size:10.0pt;font-family:tahoma,sans-serif;color:black> $final <b style=color:red></b></pre>
<p>
</dd></span></b></p>”
#Mail info
$mailmessage.from = $emailfrom
$mailmessage.To.add($sendto)
$mailmessage.Subject = $emailsubject
$mailmessage.Body = $body
$mailmessage.IsBodyHTML = $true
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
$SMTPClient.Send($mailmessage)

}
SendMail
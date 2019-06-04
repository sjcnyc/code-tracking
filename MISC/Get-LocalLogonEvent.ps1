$scriptDate = get-date -f ('MM-dd-yyy hh:mm:ss tt')
#region Function to test if number is even
Function check-even ($num) {[bool]!($num%2)}
#endregion
$Date = [DateTime]::Now.AddDays(-1)
$Date.tostring('MM-dd-yyyy'), $env:Computername
$results = @()




#region HTML Header and CSS
$HeaderHTML = 
@"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>My Systems Report</title>
<style type="text/css">
<!--
body, p, th, td, h1, a:link {font-family:Verdana,Arial;font-size:8.5pt;color:#244F54;text-decoration:none;}
h1 {font-size:12pt;letter-spacing:1pt;word-spacing:1pt;font-weight:bold;}
table, td, th { border: 1px solid #244F54;border-collapse:collapse;padding:4px;}
td.activity {background:#A4BCC2;font-weight:bold;}
td.alert {background:#A4BCC2;font-weight:bold;}
td.result, a:link {color:#244F54;}
tr.odd td {background:#E8F3F8;color:#244F54;}
tr.even td {background:#DBE6EC;color:#244F54;}
p {font-weight:normal;color:#244F54;letter-spacing:1pt;word-spacing:1pt;font-size:9px;}
-->
</style>
</head>
<body>

"@
#endregion

Get-EventLog 'Security' -After $Date `
    | Where-Object -FilterScript {$_.EventID -eq 4624 -and $_.ReplacementStrings[4].Length -gt 10 -and $_.ReplacementStrings[5] -notlike "*$"} `
    | foreach-Object {
        $row = '' | Select-Object UserName, LoginTime
        $row.UserName = $_.ReplacementStrings[5]
        $row.LoginTime = $_.TimeGenerated



 ForEach-Object { $i++; $_ }
    # Construct alternate td colors 
    if (check-even $i) {
        $results += "<tr class='even'><td>$($row.username)</td><td>$($row.logintime)</td></tr>"
    }
    else {
        $results += "<tr class='odd'><td>$($row.username)</td><td>$($row.logintime)</td></tr>"
        }
        }

#region HTML Body
$BodyHTML = 
@"
<h1>Powershell Script Alert</h1>
<table>
<tr><td class='alert'>Execution Time:</td><td class='result'>$($scriptDate)</td></tr>
<tr><td class='alert'>Script Server:</td><td class='result'>$($env:computername)</td></tr>
<tr><td class='alert'>Job Type:</td><td class='result'>Event Log</td></tr>
<tr><td class='alert'>Job Action:</td><td class='result'>Report last logon</td></tr>
<tr><td class='alert'>Job Status:</td><td class='result'>Successful</td></tr>
</table>
<h1>Activity Log</h1>
<p>
<table>
<tr><td class='activity'>Name</td><td class='activity'>Logon Time</td></tr>
$($results)<br>
</table>
</p>
"@
#endregion


#region HTML Footer
$FooterHTML = 
@"
<p>
Report Generated: $(get-date -f ('MM-dd-yyy hh:mm:ss tt'))
</div>
</body>
</html>
"@
#endregion

#region Construct HTML
    $MessageHTML = $HeaderHTML + $bodyHTML + $FooterHTML
#endregion

#region Email Information
$smtp    = 'ussmtp01.bmg.bagint.com'
$from    = 'poshalerts@sonymusic.com'   
$to      = 'sean.connealy@sonymusic.com'
$subject = 'Powershell Script Alert: Logon Intrusion'
#endregion

$emailParams = 
@{
    to = $to  
    from = $from
    subject = $subject
    smtpserver = $smtp
    body = ($MessageHTML | Out-String)
    bodyashtml = $true
}


Send-MailMessage @emailParams
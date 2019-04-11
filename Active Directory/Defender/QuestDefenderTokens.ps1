#Get-QADObject -SizeLimit 0 -IncludeAllProperties -Type "defender-tokenClass" | 
#Where-Object { $_."defender-tokenUsersDNs" -eq $null -and $_.name -like "PDWIN*" } | 
#    select name, description <#
 #   Foreach-Object {
 #       Remove-QADObject $_.name 
 #       } #>



#http://stuharrison.blogspot.com/2009/07/quest-defender-meets-powershell.html


Add-PSSnapin -Name Quest.ActiveRoles.ADManagement -ea 0
$scriptDate = Get-Date -format 'ddd MMM dd HH:mm:ss yyy'
#region Function to test if number is even
Function Get-EvenNumber  {
   param
   (
     [Object]
     $num
   )
[bool]!($num%2)}
#endregion

#region vars
$results = @()
$i = 0
$Currentdate = get-date
$Date = get-date -f ('MM-dd-yyyy')
$source = 'some ou'
#endregion

#region Email Information
$smtp    = 'ussmtp01.bmg.bagint.com'
$from    = 'poshalerts@sonymusic.com'   
$to      = 'sean.connealy@sonymusic.com'#,"Alex.Moldoveanu@sonymusic.com","brian.lynch@sonymusic.com","kim.lee@sonymusic.com","alfredo.torres.peak@sonymusic.com"
$subject = '[Flush Unassigned Tokens] Execution Report.'
#endregion

#region HTML Header and CSS
$HeaderHTML = 
@"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>[Flush Unassigned Tokens] Execution Report.</title>
<style type="text/css">
<!--
body, p, th, td, h1, a:link {font-family:Verdana,Arial;font-size:8.5pt;color:#244F54;text-decoration:none;}
h1 {font-size:8.5pt;letter-spacing:1pt;word-spacing:1pt;font-weight:bold;}
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

#region Call Get-QadComputer
$tokens=Get-QADObject -SizeLimit 0 -IncludeAllProperties -Type 'defender-tokenClass' | 
    Where-Object { $_.'defender-tokenUsersDNs' -eq $null -and $_.name -like 'PDWIN*' }
#endregion

#region HTML Body
$BodyHTML = 
@"
<h1>[Flush Unassigned Tokens]</h1>
<table>
<tr><td class='alert'>Started:</td><td class='result'>$($scriptDate)</td></tr>
<tr><td class='alert'>Job Type:</td><td class='result'>AD Object</td></tr>
<tr><td class='alert'>Job Action:</td><td class='result'>Flush Unassigned Defender Tokens</td></tr>
<tr><td class='alert'>Job Status:</td><td class='result'>Successful</td></tr>
</table>
<h1>Activity Log</h1>
<p>
($($tokens.Count)) Token(s) flushed from:<br>$($tokens.ParentContainer)<br>
</p>
<table>
"@
#endregion

#region Main Loop
foreach ($tok in $tokens) {
    ForEach-Object { $i++; $_ }
    # Construct alternate td colors 
    if (Get-EvenNumber $i) {
        $results += "<tr class='even'><td>$($tok.'name')</td><td>$($tok.'description')</td></tr>"
    }
    else {
        $results += "<tr class='odd'><td>$($tok.'name')</td><td>$($tok.'description')</td></tr>"
    }
    # Delete defender tokens
    write-host "Flushing: $($tok.'name')"
    }
#endregion

#region Loop $results @()
$BodyHTML += "<tr><td class='activity'>Name</td><td class='activity'>Description</td></tr>"
foreach ($result in $results) {
    $bodyHTML += $result
}
#endregion

#region HTML Footer
$FooterHTML = 
@"
</table>
<p>
Report Generated: $(Get-Date -format 'ddd MMM dd HH:mm:ss yyy')
</div>
</body>
</html>
"@
#endregion

#region Construct HTML
    $MessageHTML = $HeaderHTML + $bodyHTML + $FooterHTML
#endregion

#region Email Report
$emailParams = 
@{
    to = $to  
    from = $from
    subject = $subject
    smtpserver = $smtp
    body = ($MessageHTML | Out-String)
    bodyashtml = $true
}

if ($tokens -ne $null){
    Send-MailMessage @emailParams
}
else {
}

#endregion  

#region Function to test if number is even
Function check-even  {
  param
  (
    [System.Object]
    $num
  )
[bool]!($num%2)}
#endregion

#region Script location function
function Get-ScriptDirectory { 
  if($hostinvocation -ne $null)
  {
    Split-Path $hostinvocation.MyCommand.path
  }
  else
  {
    Split-Path $script:MyInvocation.MyCommand.Path
  }
}
#endregion

$currentTime = Get-Date -f F
$comps = Get-QADComputer -SearchRoot 'bmg.bagint.com/USA/GBL/W7Build' | ForEach-Object { $_ } | 
    Where-Object { $_.OSVersion -like '6.1*' -and $_.computername -like 'US*' -or $_.computername -like 'USL*' }

# Email information
$smtp    = 'ussmtp01.bmg.bagint.com'
$from    = 'Win7-OU-Moves@sonymusic.com'   
$to      = 'sean.connealy@sonymusic.com'#,"Alex.Moldoveanu@sonymusic.com" #,"kim.lee@sonymusic.com"
$subject = 'Daily Windows 7 Workstation OU Moves'

# Construct HTML Header and CSS
$HeaderHTML = @"
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

$results = @()
$i = 0
$dest = 'USA/GBL/WST/Windows7'
# Main Loop
foreach ($comp in $comps){
  ForEach-Object { $i++; $_ }
  # Construct alternate td colors 
  if (check-even $i) {
    $results += "<tr class='even'><td>$($comp.name)</td><td>Computer</td><td>$($dest)</td></tr>"
  }
  else {
    $results += "<tr class='odd'><td>$($comp.name)</td><td>Computer</td><td>$($dest)</td></tr>"
  }
  # Move AD Objects
  #Move-QADObject -Identity $comp -To "bmg.bagint.com/USA/GBL/WST/Windows7" 
}

# Construct Body HTML
$BodyHTML = @"
<h1>Powershell Script Alert</h1>
<table>
<tr><td class='alert'>Script Server:</td><td class='result'>$env:computername</td></tr>
<tr><td class='alert'>Job Status:</td><td class='result'>Successful</td></tr>
<tr><td class='alert'>Job Type:</td><td class='result'>AD Object Move</td></tr>
<tr><td class='alert'>Target:</td><td class='result'>$($dest)</td></tr>
<tr><td class='alert'>Execution Time:</td><td class='result'>$currentTime</td></tr>
<tr><td class='alert'>Contact:</td><td class='result'><a href="mailto:sconnea@sonymusic.com?subject=Home Drive Folder Offboarding">Sean Connealy</a> - 201-777-3487</td></tr>
</table>
<h1>Activity Log</h1>
<p>
($($comps.Count)) AD Objects moved from USA/GBL/Win7Build OU.<br>
</p>
<table>
<tr><td class='activity'>Name</td><td class='activity'>Type</td><td class='activity'>Destiniation OU</td></tr>
"@

# Loop $results @()
foreach ($result in $results) {
  $bodyHTML += $result
}

# Construct Footer HTML    
$FooterHTML = @"
</table>
<p>
Report Generated: $(Get-Date -f F)
</div>
</body>
</html>
"@

# Construct HTML 
$MessageHTML = $HeaderHTML + $bodyHTML + $FooterHTML

# Email report
if ($comps -ne $null){
  Send-MailMessage -To $to -From $from -subject $subject -SmtpServer $smtp -Body ($MessageHTML | Out-String) -BodyAsHtml
}
else { Write-Host 'no comps yo!'}
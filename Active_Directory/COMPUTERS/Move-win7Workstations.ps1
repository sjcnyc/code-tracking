Add-PSSnapin -Name Quest.ActiveRoles.ADManagement -ea 0

$currentTime = Get-Date -format 'ddd MMM dd HH:mm:ss yyy'
$comps = Get-QADComputer -SearchRoot 'bmg.bagint.com/USA/GBL/W7Build' | ForEach-Object { $_ } | 
    Where-Object { $_.OSVersion -like '6.1*' -and $_.computername -like 'USD*' -or $_.computername -like 'USL*' }

# Function to test if number is even
Function check-even  {
  param
  (
    [System.Object]
    $num
  )
[bool]!($num%2)}

$results = @()
$i = 0
$dest = 'USA/GBL/WST/Windows7'
# Main Loop
foreach ($comp in $comps){
  ForEach-Object { $i++; $_ }
  # Construct alternate td colors 
  if (check-even $i) {
    $results += "<tr><td>$($comp.name)</td><td>Computer</td><td>$($dest)</td></tr>"
  }
  else {
    $results += "<tr><td>$($comp.name)</td><td>Computer</td><td>$($dest)</td></tr>"
  }
  # Move AD Objects
  # Move-QADObject -Identity $comp -To "bmg.bagint.com/USA/GBL/WST/Windows7" 
}

# Loop $results @()
$result1 = foreach ($result in $results) {
  $bodyHTML += $result
}


# Email information
$smtp    = 'ussmtp01.bmg.bagint.com'
$from    = 'poshalerts@sonymusic.com'   
$to      = 'sean.connealy@sonymusic.com'#,"Alex.Moldoveanu@sonymusic.com","brian.lynch@sonymusic.com","kim.lee@sonymusic.com","alfredo.torres.peak@sonymusic.com"
$subject = '[Move Windows7 objects] Execution Report.'

# Construct HTML Header and CSS
$HeaderHTML = @"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>[Move Windows7 objects.</title>
<style type="text/css">
<!--
-->
</style>
</head>
"@

# Construct Body HTML
$BodyHTML = @"
<body style='font-family:Verdana,Arial;font-size:8.5pt;text-decoration:none;background-color: #c7c7c7;'>
<table cellpadding='0' cellspacing='0' border='0' width='100%' align='center'>
<tr><td>
<table align='center' cellpadding='0' cellspacing='0' margin='0' style='background:#fff'>
<tr><td>
<Table align='center' width='100%' cellpadding='0' cellspacing='0'>
<tr><td style='background:#000;font-family:Verdana,Arial;font-size:26px;color:#fff;font-weight:bold' align='center'>
Move Windows 7 Objects
</td></tr>
</table>
<h1 style='color:#c7c7c7;font-size:12px;'>Execution Report.</h1>
<table border='1px solid #000'>
<tr><td>Started:</td><td>$currentTime</td></tr>
<tr><td>Job Type:</td><td>AD Object Move</td></tr>
<tr><td>Target:</td><td'>$($dest)</td></tr>
<tr><td>Job Status:</td><td'>Successful</td></tr>
</table>
<h1>Activity Log</h1>
<p>
($($i)) AD Objects moved from USA/GBL/Win7Build OU.<br>
</p>
<table>
<tr><td class='activity'>Name</td><td class='activity'>Type</td><td class='activity'>Destiniation OU</td></tr>
"@

# Construct Footer HTML    
$FooterHTML = @"
</table>
<p>
Report Generated: $(Get-Date -format 'ddd MMM dd HH:mm:ss yyy')
</div>
<Table align='center' width='100%' cellpadding='0' cellspacing='0'>
<tr><td style='background:#000;font-family:Verdana,Arial;font-size:12px;color:#fff;font-weight:normal' align='center'>
Powershell Alert
</td></tr>
</table>
</td>
</tr>
</table>
</td>
</tr>
<table>
</body>
</html>
"@

# Construct HTML 
$MessageHTML = $HeaderHTML + $bodyHTML + $FooterHTML

# Email report
#if ($comps -ne $null){
Send-MailMessage -To $to -From $from -subject $subject -SmtpServer $smtp -Body ($MessageHTML | Out-String) -BodyAsHtml
#}
#else { Write-Host "no comps yo!"}
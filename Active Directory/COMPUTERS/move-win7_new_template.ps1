#   Name    :  Move-Win7Wst.ps1
#   Author  :  Sean Connealy
#   Company :  Sony Music Entertainment
#   Created :  2/02/2012
#   Modified:  11/13/2013

Add-PSSnapin -Name Quest.ActiveRoles.ADManagement -ea 0

$comps = @("comp1","comp2","comp3","comp4","comp4","comp6","comp7","comp8","comp9","comp10","comp11")

$currentTime = "{0:G}" -f (Get-Date)
#$comps = Get-QADComputer -SearchRoot 'bmg.bagint.com/USA/GBL/W7Build' | ForEach-Object { $_ } | 
#    Where-Object { $_.OSVersion -like "6.1*" -and $_.computername -like "USD*" -or $_.computername -like "USL*" }

# Email information
$smtp    = "ussmtp01.bmg.bagint.com"
$from    = "poshalerts@sonymusic.com"   
$to      = "sean.connealy@sonymusic.com" #,"Alex.Moldoveanu@sonymusic.com"#,"sjcnyc@gmail.com","sjcnyc@outlook.com"
$subject = "Execution Report"

# Function to test if number is even
Function check-even ($num) {[bool]!($num%2)}

$results = @()
$i = 0
$dest = "USA/GBL/WST/Windows7"
$headerTitle = "Move Windows 7 Objects"

# main loop begin
foreach ($comp in $comps){
  ForEach-Object { $i++; $_ }

$EMAILHEADER =@"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Demystifying Email Design</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
</head>
<body style="margin: 0; padding: 0;">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td style="padding: 0 0 0 0;">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="border: 1px solid #153643; border-collapse: collapse;">
<tr>
<td align="center" bgcolor="#153643" style="padding: 30px 0 30px 0; color: #ffffff; font-size: 28px; font-weight: bold; font-family: Arial, sans-serif;">
$($headerTitle)
</td>
</tr>
"@

$tdStyle1 ="padding: 1px 5px 1px 1px; color: #153643; font-family: Arial, sans-serif; font-size: 12px; line-height: 12px; font-weight:bold"
$tdStyle2 ="border-left:1px solid #cccccc; padding: 1px 5px 1px 5px; color: #153643; font-family: Arial, sans-serif; font-size: 12px; line-height: 12px;"

$EMAILBODY =@"
<tr>
<td align="center" bgcolor="#ffffff" style="padding: 20px 20px 20px 20px;">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td style="color: #153643; padding: 0 0 5px 0; font-family: Arial, sans-serif; font-size: 20px;">
<b>Execution Report</b>
</td>
</tr>
<tr>
<td>
<Table border="0" cellpadding="o" cellspacing="0">
<tr><td style="$($tdStyle1)">Started</td><td style="$($tdStyle2)">$($currentTime)</td></tr>
<tr><td style="$($tdStyle1)">Type</td><td style="$($tdStyle2)">Object Move</td></tr>
<tr><td style="$($tdStyle1)">Target</td><td style="$($tdStyle2)">USA/GBL/WST/Windows7</td></tr>
<tr><td style="$($tdStyle1)">Status</td><td style="$($tdStyle2)">Successful</td></tr>
</table>
</td>
<tr>
<td style="color: #153643; padding: 10px 0 5px 0; font-family: Arial, sans-serif; font-size: 20px;">
<b>Activity Log</b>
</td>
</tr>
<tr>
<td style="color: #153643; padding: 10px 0 10px 0; font-family: Arial, sans-serif; font-size: 12px; line-height: 12px;">
($($i)) Computer object(s) moved
</td>
</tr>
<!-- ###################################### -->
<tr>
<td>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td width="50%" valign="top" style="padding: 0 0 0 0; color: #153643; font-family: Arial, sans-serif; font-size: 12px; line-height: 12px; font-weight:bold;">Name</td>
<td width="50%" valign="top" style="padding: 0 0 0 0; color: #153643; font-family: Arial, sans-serif; font-size: 12px; line-height: 12px; font-weight:bold;">Type</td>
</tr>
"@

$tdStyle3 = "background-color:#cccccc; padding: 0 0 0 0; color: #153643; font-family: Arial, sans-serif; font-size: 12px; line-height: 12px;"
$tdStyle4 = "padding: 0 0 0 0; color: #153643; font-family: Arial, sans-serif; font-size: 12px; line-height: 12px;"

# Main Loop coutinued
    # Construct alternate td colors 
	if (check-even $i) {
	    $results += "<tr><td width='50%' valign='top' style='$($tdStyle3)'>$($comp)</td><td width='50%' valign='top' style='$($tdStyle3)'>Computer</td>"
       }
    else {
        $results += "<tr><td width='50%' valign='top' style='$($tdStyle4)'>$($comp)</td><td width='50%' valign='top' style='$($tdStyle4)'>Computer</td>"
       }
    # Move AD Objects
   # Move-QADObject -Identity $comp -To "bmg.bagint.com/USA/GBL/WST/Windows7" 
}

# Loop $results @()
foreach ($result in $results) {
	$EMAILBODY += $result
}

$EMAILFOOTER =@"
</table></td></tr></table></td></tr>
<tr><td bgcolor="#153643" style="padding: 10px 0 10px 0;">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr><td align="center" style="color: #ffffff; font-family: Arial, sans-serif; font-size: 12px;" width="100%">
Report Generated: $("{0:G}" -f (Get-Date))<br/>
</td></tr></table></td></tr></table></td></tr></table>
</body>
</html>
"@

$EMAIL = $EMAILHEADER + $EMAILBODY + $EMAILFOOTER

Send-MailMessage -To $to -From $from -subject $subject -SmtpServer $smtp -Body ($EMAIL | Out-String) -BodyAsHtml
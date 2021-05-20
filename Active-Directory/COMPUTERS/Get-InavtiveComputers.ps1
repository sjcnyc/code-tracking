Add-PSSnapin -Name Quest.ActiveRoles.ADManagement -ea 0
$scriptDate = Get-Date -format 'ddd MMM dd HH:mm:ss yyy'
#region Function to test if number is even
Function Check-Even  {
  param
  (
    [System.Object]
    $num
  )
[bool]!($num%2)}
#endregion

#region Function Get-ScriptDir
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

#region Vars and Props
$QADprops = 
@{N='Computer Name';E={$_.computername}}, `
	@{N='Last Logon TimeStamp';E={$_.lastlogontimestamp}}, `
	@{N='OS Name';E={$_.osname}}, `
	@{N='Parent Container DN';E={$_.parentcontainerdn}};

$QADParams = 
@{
	sizelimit = '0'
	pagesize = '2000'
	dontusedefaultincludedproperties = $true
	includedproperties = @('ComputerName', 'LastLogonTimeStamp', 'OSName', 'ParentContainerDN')
	searchroot = @('bmg.bagint.com/USA/GBL/WST/Windows7','bmg.bagint.com/USA/GBL/WST/XP')
}


$results = @()
$i = 0
$Currentdate = get-date
$Date = get-date -f ('MM-dd-yyyy')
$Days = 90
$currentDir = Get-ScriptDirectory
$CSV = "$($currentDir)\inactive_computers-$($Date).csv"
$attachment = $false
$numComps = 30
$source = 'USA/GBL/WST/' 
$dest = 'NYCtest/TST/WST/Disabled'
#end region

#region Email Information
$smtp    = 'ussmtp01.bmg.bagint.com'
$from    = 'poshalerts@sonymusic.com'   
$to      = 'sean.connealy@sonymusic.com'#,"Alex.Moldoveanu@sonymusic.com","brian.lynch@sonymusic.com","kim.lee@sonymusic.com","alfredo.torres.peak@sonymusic.com"
$subject = '[Move Inactive Computer Objects] Execution Report.'
#endregion

#endregion

#region Call Get-QadComputer
$Comps=Get-QADComputer @QADParams | 
Where-Object { $_.LastLogonTimeStamp -ne $Null -and ($Currentdate-$_.LastLogonTimeStamp).Days -gt $Days -and $_.parentcontainer -notlike '*Exclude*' } |
Select-Object $QADprops -ErrorAction 0
#endregion

#region HTML Header and CSS
$HeaderHTML = 
@"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>[Move Inactive Computer Objects] Execution Report.</title>
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

#region Main Loop
foreach ($comp in $comps) {
  ForEach-Object { $i++; $_ }
  # Construct alternate td colors 
  if (check-even $i) {
    $results += "<tr class='even'><td>$($comp.'Computer Name'.Replace('$', ''))</td><td>Computer</td><td>$($dest)</td></tr>"
  }
  else {
    $results += "<tr class='odd'><td>$($comp.'Computer Name'.Replace('$', ''))</td><td>Computer</td><td>$($dest)</td></tr>"
  }
  # Disable AD Objects
  ### Disable-QADComputer -Identity $comp.'Computer Name' -ErrorAction 0 | out-null
  write-host "Disabling: $($comp.'Computer Name'.Replace('$', ''))"
  # Update AD Object description with original ou/dn
  # Set-QADComputer $comp.'Computer Name' -ObjectAttributes @{description=$comp.'Parent Container DN'}
  #write-host "Updating description: $($comp.'Parent Container DN')"
  # Move AD Objects
  ### Move-QADObject -Identity $comp."Computer Name" -To "bmg.bagint.com/$($dest)" -ErrorAction 0 | out-null
  write-host "Moving: $($comp.'Computer Name'.Replace('$', ''))"
  
}
#endregion

#region HTML Body
$BodyHTML = 
@"
<h1>Move Inactive Computer Objects</h1>
<table>
<tr><td class='alert'>Started:</td><td class='result'>$($scriptDate)</td></tr>
<tr><td class='alert'>Job Type:</td><td class='result'>AD Object</td></tr>
<tr><td class='alert'>Job Action:</td><td class='result'>Move Computers Inactive $($days) Days</td></tr>
<tr><td class='alert'>Source:</td><td class='result'>$($source)</td></tr>
<tr><td class='alert'>Destination:</td><td class='result'>$($dest)</td></tr>
<tr><td class='alert'>Job Status:</td><td class='result'>Successful</td></tr>
</table>
<h1>Activity Log</h1>
<p>
($($comps.Count)) Computer(s) moved from $($source) OU.<br>
</p>
<table>
"@
#endregion

#region Loop $results @()
if ($comps.Count -gt $numComps) {
  $attachment = $true
  $comps | Export-csv $CSV -notype    
  $BodyHTML += '<tr><td><h1>Please see attached csv file.</h1></td></tr>'
} 
else {
  $BodyHTML += "<tr><td class='activity'>Name</td><td class='activity'>Type</td><td class='activity'>Destiniation OU</td></tr>"
  foreach ($result in $results) {
    $bodyHTML += $result
  }
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

if ($comps -ne $null){
  if ($attachment) {
  Send-MailMessage @emailParams -Attachments $CSV }
  else {
    Send-MailMessage @emailParams
  }
}
#endregion    
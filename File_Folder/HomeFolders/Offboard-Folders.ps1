Add-PSSnapin -Name Quest.ActiveRoles.ADManagement -ea 0

$currentTime = get-date -f F
$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
$target  = "\\storage\home$"
$exclude = '^iroyalty$|^SPECPROD$|^NAEXEC$|^ARISTA$|^FINANCE$|^HR$|^dist$|^MIS$|^LEGAL$|^IST$|^RCALABEL$'
$folders = Get-ChildItem -Path $target | Where-Object { $_.Name -notmatch $exclude -and ($_.PSISContainer) } | Select-Object name
$logfile = @() 
$results = @()
$i = 0

# Email information
$smtp    = 'ussmtp01.bmg.bagint.com'
$from    = 'Off-boarding@sonymusic.com'   
$to      = 'sean.connealy@sonymusic.com'#,"Alex.Moldoveanu@sonymusic.com" ,"kim.lee@sonymusic.com"
$subject = 'Home Drive Off-boarding'

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

# Function to test if number is even
Function Check-Even  {
  param
  (
    [System.Object]
    $num
  )
[bool]!($num%2)}

# #comments are for debug when not running scheduled task

# Main foreach loop
foreach($folder in $folders){
  Write-Host ''
  $userid=''
  $user=Get-QADUser $folder.name
  $useracc=$user.AccountIsDisabled
  $userid=$user.samaccountname
  $newid='_x_' + $folder.name
  $fullpath=$target + '\' + $folder.name
  #"Account disabled: {0} " -f $user.AccountIsDisabled
  $acl = $fullpath | get-acl | % {$_.access } | % {$_.IdentityReference.value} #| ? {$_.IdentityReference.value -notlike "*@bmg.bagint.com"}
  if ($userid.length -eq '0' -and $folder.name -notmatch $exclude -and $folder.name -notlike "^am_*$|^sc_*$|^_x_*$" -and $acl -notlike '*@bmg.bagint.com' ) {
    
    %{$i++;$_}
    Write-Host 'No owner found or account disabled' -ForegroundColor Red
    # uncomment below to rename folders
    #Rename-Item -Path $fullpath -NewName $newid
    Write-Host 'Folder renamed to: '  $newid
    
    # Construct alternate td colors 
    if (check-even $i) {
      $results += "<tr class='even'><td>$($fullpath)</td><td>$($newid)</td></tr>"
    }
    else {
      $results += "<tr class='odd'><td>$($fullpath)</td><td>$($newid)</td></tr>"
    }
  }
  else {
    Write-Host 'Owner found' $user -ForegroundColor Green
  }  
}

# Construct Body HTML
$BodyHTML = @"
<h1>Powershell Script Alert</h1>
<table>
<tr><td class='alert'>Script Server:</td><td>$env:computername</td></tr>
<tr><td class='alert'>Job Status:</td><td>Successful</td></tr>
<tr><td class='alert'>Job Type:</td><td>Folder off-boarding</td></tr>
<tr><td class='alert'>Target:</td><td>$target</td></tr>
<tr><td class='alert'>Destination:</td><td>\\storage\offboard$\</td></tr>
<tr><td class='alert'>Execution Time:</td><td>$currentTime</td></tr>
<tr><td class='alert'>Contact:</td><td><a href="mailto:sconnea@sonymusic.com?subject=Home Drive Folder Offboarding">Sean Connealy</a> - 201-777-3487</td></tr>
</table>
<h1>Activity Log</h1>
<p>
($($folders.Count)) Folders processed.<br>
($i) Folders off-boarded.
</p>
<table>
<tr><td class='activity'>Folder Path</td><td class='activity'>Folder Renamed</td></tr>   
"@

# Loop $results @()
foreach ($result in $results) {
  $bodyHTML += $result
}

$completetime = get-date -f F
# Construct Footer HTML    
$FooterHTML = @"
</table>
<p>
Report Generated: $completetime
</div>
</body>
</html>
"@

# Construct HTML 
$MessageHTML = $HeaderHTML + $bodyHTML + $FooterHTML

# Email report
Send-MailMessage -To $to -From $from -subject $subject -SmtpServer $smtp -Body ($MessageHTML | Out-String) -BodyAsHtml

# Enable logging
#$filename = "home_{0:yyyyMMdd-HHmmss}.txt" -f (Get-Date)
#$logfile > c:\temp\$($filename)
#$results | Export-Csv c:\temp\home_offboard.csv -NoTypeInformation
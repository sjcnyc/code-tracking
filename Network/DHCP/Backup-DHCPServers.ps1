#   Name    :  dhcpBackup.ps1
#   Autor   :  Sean Connealy
#   Company :  Sony Music Entertainment
#   Created :  6/27/2013

. .\HTMLTable.ps1

Add-Type -AssemblyName System.Web

$style1 = '<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 8pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #666666;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#eeeeee;background-color:#333333;border:1px solid black;padding:4px;}
  td {padding:4px; border:1px solid black;}
  .odd { background-color:#ffffff; }
  .even { background-color:#CFCFCF; }
</style>'

$DhcpServers = @('USNYCPWFS02','USNYCVWDHP002','USCULVWDHP001','USCULVWDHP002','MIASBMEWFP001','MIASBMEWMAC001')
$StartTime = get-date -Format G

$DHCPServerArray =@()

foreach ($DHCPServer in $DhcpServers) {

    $DHCPServerPath = "\\$($DHCPServer)\C$\Windows\System32\dhcp"
    $LOGPath    = "\\storage\worldwide$\SecurityLogs\DHCP\$($DhcpServer)"

    $checkdir = Test-Path -PathType Container $LOGPath
     if ($checkdir -eq $false) {
        New-Item $LOGPath -type Directory | Out-Null
    }
    
    #Get Yestedays Date In Month, Day, Year format
    $yesterday=(get-date (get-date).AddDays(-1) -uformat %Y%m%d)
     
    #Get the first 3 letters of the day name from yesterday
    $logdate=([string]((get-date).AddDays(-1).DayofWeek)).substring(0,3)
     
    #Change path to DHCP log folder, copy yesterdays log file to backup location
    Copy-Item "$($DHCPServerPath)\DhcpSrvLog-$($logdate).log" $LOGPath 
     
    #Rename log file with yesterdays date
    Rename-Item "$($LOGPath)\DhcpSrvLog-$($logdate).log" "$($yesterday).log"
     
    #Dump DHCP database at the end of the month
    $LastDay = ((Get-Date -Day 01).AddMonths(1)).AddDays(-1)
    $LastDay = get-date $LastDay -UFormat %d
    
    $currentday = (get-date -UFormat %d)
    
    if ( $currentday -eq $LastDay) {
        
        $Today=(get-date -uformat %Y%m%d)
        $dumpfile="$($Today)-DHCP_DB.txt"
        Invoke-Command -ScriptBlock{ netsh.exe dhcp server \\$($DHCPServer) dump > "$($LOGPath)\$($dumpfile)" } 
        $DBBackup = 'Yes'
    }
    else {
        $DBBackup = 'No'

        }
        
   $DHCPObj = [pscustomobject]@{
      'DHCP Server'     = $DHCPServer
      'Source Log'      = "$($DHCPServerPath)\DhcpSrvLog-$($logdate).log"
      'Destination Log' = "$($LOGPath)\$($yesterday).log"
   }

    $DHCPServerArray += $DHCPObj
}

$HTML = New-HTMLHead -title 'DHCP Server Backup' -style $style1
  $HTML += '<h3>DHCP Server Backup Report.</h3>'
  $HTML += "<h4>($($DhcpServers.Count)) Servers Backed Up.</h4>"
  $HTML += "<h4>Script Started: $($StartTime)</h4>"
  $html += "<h4>Database Backup: $($DBBackup)</h4>"
  $HTML += New-HTMLTable -InputObject $($DHCPServerArray)
  $HTML += "<h4>Script Completed: $(get-date -Format G)</h4>"

$smtpProps =@{
    smtpserver = 'ussmtp01.bmg.bagint.com'
    From = 'Posh Alerts poshalerts@sonymusic.com'
    To = 'sean.connealy@sonymusic.com','Alex.Moldoveanu@sonymusic.com','kim.lee@sonymusic.com','brian.lynch@sonymusic.com'
    Subject = 'DHCP Server Backup Report'
    Body = $HTML
    BodyasHTML = $true
}
    
Send-MailMessage @smtpProps
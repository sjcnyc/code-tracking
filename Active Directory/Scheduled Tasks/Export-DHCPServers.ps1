$AutomationPSCredentialName = "t1_cred"
#$Credential = Get-AutomationPSCredential -Name $AutomationPSCredentialName -ErrorAction Stop
# vars
$Path = '\\storage.bmg.bagint.com\Worldwide$\SecurityLogs\DHCP\_FullExport\'
$Date = (get-date -f yyyy-MM-dd)
$PSArrayList = New-Object System.Collections.ArrayList

$getADComputerSplat = @{
  SearchBase = "OU=DHCP,OU=GBL,OU=USA,OU=NA,OU=SRV,OU=Tier-1,DC=me,DC=sonymusic,DC=com"
  Properties = '*'
  Filter     = '*'
}
$DHCPServers = Get-ADComputer @getADComputerSplat

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

foreach ($Server in $DHCPServers) {
  $FullPath = $Path + $Server.Name

  $ServerInfo = [pscustomobject]@{
    'Server Name' = $Server.Name
    'Backup' = $FullPath
  }

    if (!(Test-Path -Path $fullPath -PathType Container)) {New-Item -Path $fullPath -ItemType Directory}

    Export-DhcpServer -ComputerName $Server.Name -File "$($fullPath)\$($Server.Name)_$($Date).xml" -Verbose -ErrorAction Continue

  [void]$PSArrayList.Add($ServerInfo)
}

$InfoBody = [pscustomobject]@{
  'Task'          = "Azure Hybrid Runbook Worker - Tier-1"
  'Action'        = "Backup ME DHCP Servers"
  'Total Servers' = $PSArrayList.Count
}

$HTML = New-HTMLHead -title $title -style $style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
$HTML += "<h4>Script Started: $($StartTime)</h4>"
$HTML += New-HTMLTable -InputObject $($PSArrayList)
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$emailParams = @{
  to         = 'sean.connealy@sonymusic.com' #,'Alex.Moldoveanu@sonymusic.com','kim.lee@sonymusic.com','brian.lynch@sonymusic.com'
  from       = 'Posh Alerts poshalerts@sonymusic.com'
  subject    = $title
  smtpserver = 'ussmtp01.bmg.bagint.com'
  body       = ($HTML | Out-String)
  bodyashtml = $true
}

Send-MailMessage @emailParams
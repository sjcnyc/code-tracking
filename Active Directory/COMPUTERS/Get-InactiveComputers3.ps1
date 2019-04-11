#Requires -Version 3.0 
#Requires -PSSnapin Quest.ActiveRoles.ADManagement
<# 
    .SYNOPSIS  
  
    .DESCRIPTION  
  
    .NOTES 
      File Name  : Get-InactiveComputers3
      Author     : Sean Connealy
      Requires   : PowerShell Version 3.0 
      Date       : 6/26/2015
  
    .LINK 
      This script posted to: http://www.github/sjcnyc
  
    .EXAMPLE
  
#>

$ScriptRoot = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptRoot\HTMLTable.ps1"

$style1 = '<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 8pt;}
  h1 {color:#08869C;}
  h2 {color:#08869C;}
  h3 {color:#08869C;font-size: 11pt;}
  h4 {font-size: 8pt;font-weight: normal;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#eeeeee;background-color:#333333;border:1px solid black;padding:4px;}
  td {padding:4px; border:1px solid black;}
  .odd { background-color:#ffffff; }
  .even { background-color:#CFCFCF; }
</style>'

$Days        = 90
$smtp        = 'ussmtp01.bmg.bagint.com'
$from        = 'poshalerts@sonymusic.com'   
$to          = 'sean.connealy@sonymusic.com'
$subject     = 'Inavtive Computer Report'

$QADParams = @{
  sizelimit                        = '0'
  pagesize                         = '2000'
  dontusedefaultincludedproperties = $true
  includedproperties               = @('ComputerName', 'LastLogonTimeStamp', 'OSName', 'ParentContainer')
  searchroot                       = @('bmg.bagint.com/USA/GBL/WST/Windows7', 'bmg.bagint.com/USA/GBL/WST/XP')
}

$Comps = Get-QADComputer @QADParams | 
  Where-Object {
    $_.LastLogonTimeStamp -ne $Null -and ($Currentdate-$_.LastLogonTimeStamp).Days -gt $Days -and $_.parentcontainer -notlike '*Exclude*' 
  } | Select-Object computername, osname, lastlogontimestamp, parentcontainer -ErrorAction 0

if ($comps) {

  $compinfocomplete = @()
  foreach ($comp in $Comps) 
  {
    $compinfo = [pscustomobject]@{
      'Computer'  = $comp.computername.Replace('$', '')
      'LastLogon' = $comp.lastlogontimestamp
      'OS'        = $comp.osname
      'Source OU' = $comp.parentcontainer.Replace('bmg.bagint.com', '')
      'target OU' = '/NYCtest/TST/WST/Disabled'
    }
    $compinfocomplete += $compinfo        
  }

  $HTML = New-HTMLHead -title 'Inactive Computers' -style $style1
  $HTML += '<h2>Inactive Computer Report</h2>'
  $HTML += "<h4>Script Started: $($StartTime)</h4>"
  $HTML += "<h4>($($comps.Count)) Computer(s) moved to: $($compinfo.'target OU')</h4>"
  $HTML += New-HTMLTable -InputObject $($compinfocomplete) -Properties 'Computer', 'LastLogon', 'OS', 'Source OU'
  $HTML += "<h4>Script Completed: $($StartTime)</h4>"

  $emailParams = @{
    to         = $to
    from       = $from
    subject    = $subject
    smtpserver = $smtp
    body       = ($HTML | Out-String)
    bodyashtml = $true
  }

  Send-MailMessage @emailParams
}
else {Write-Host 'Nothing to see here folks!'}

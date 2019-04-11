
<# 
    .SYNOPSIS  
    Disable AD user objects in bmg.bagint.com/USA/GBL/USR/Disabled 

    .DESCRIPTION 
    Disable AD user objects in bmg.bagint.com/USA/GBL/USR/Disabled 
    Add disabled time in object description 
  
    .NOTES 
    File Name  : Disable-UserAccounts
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 8/27/2015
  
    .LINK 
    This script posted to: http://www.github/sjcnyc
  
    .EXAMPLE
  
#>

. .\HTMLTable.ps1

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

$StartTime = get-date -Format G
$smtp        = 'ussmtp01.bmg.bagint.com'
$from        = 'Posh Alerts poshalerts@sonymusic.com'   
$to          = 'sean.connealy@sonymusic.com'#, 'Alex.Moldoveanu@sonymusic.com', 'Carol.Paterno@sonymusic.com', 'Fern.Metcalf@sonymusic.com'
$subject     = 'Disable User Report'

$QADParams = @{
  sizelimit                        = '0'
  pagesize                         = '2000'
  dontusedefaultincludedproperties = $true
  includedproperties               = @('Name', 'SAMAccountName', 'ParentContainer')
  searchroot                       = @('bmg.bagint.com/USA/GBL/USR/Disabled', 'bmg.bagint.com/USA/GBL/USR/Suspend')
}

$users = Get-QADUser -Enabled @QADParams | Select-Object Name, SAMAccountName, ParentContainer -ErrorAction 0

write-host $users.count

$userInfoComplete = @()

if ($users) {
  foreach ($user in $users) {
    $userInfo = [pscustomobject]@{
      'Name'            = $user.Name
      'SAMAccountName'  = $user.SAMAccountName
      'ParentContainer' = $user.ParentContainer
    }
  
    Disable-QADUser -Identity $user.SamAccountName -ErrorAction 0 #-WhatIf
    Write-Host "Disabling Account: $($user.SamAccountName)"
  
    $userInfoComplete += $userInfo
  }

  $HTML = New-HTMLHead -title 'Disable Users' -style $style1
  $HTML += '<h3>Disable Users Report</h3>'
  $HTML += "<h4>($($users.count)) User Accounts Disabled</h4>"
  $HTML += "<h4>Script Started: $($StartTime)</h4>"
  $HTML += New-HTMLTable -InputObject $($userInfoComplete)
  $HTML += "<h4>Script Completed: $(get-date -Format G)</h4>"

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
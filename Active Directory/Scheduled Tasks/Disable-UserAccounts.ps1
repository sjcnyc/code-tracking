#requires -Modules HTMLTable
#requires -Version 2
#requires -PSSnapin Quest.ActiveRoles.ADManagement
Add-PSSnapin -Name Quest.ActiveRoles.ADManagement 

# vars
$StartTime = Get-Date -Format G
$title = 'Disable User Report'
$msg = 'OUs: USA/GBL/USR/Disabled & USA/GBL/USR/Suspend'
$countMsg = 'User Accounts Disabled'

# params
$QADParams = @{
  SizeLimit                        = '0'
  PageSize                         = '2000'
  DontUseDefaultIncludedProperties = $true
  IncludedProperties               = @('Name', 'SAMAccountName', 'ParentContainer')
  SearchRoot                       = @('bmg.bagint.com/USA/GBL/USR/Disabled', 'bmg.bagint.com/USA/GBL/USR/Suspend')
}

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

# scriptblock
$query = Get-QADUser -Enabled @QADParams | Select-Object Name, SAMAccountName, ParentContainer -ErrorAction 0

$result = New-Object System.Collections.ArrayList

if ($query) {
  foreach ($q in $query) {
    $info = [pscustomobject]@{
      'Name'            = $q.Name
      'SAMAccountName'  = $q.SAMAccountName.ToUpper()
      'ParentContainer' = $q.ParentContainer.Replace('bmg.bagint.com/','')
    }
  
    Disable-QADUser -Identity $q.SamAccountName -ErrorAction 0 -WhatIf
  
    $result.Add($info) | Out-Null
  }

  $count = $result.Count

  $HTML = New-HTMLHead -title $title -style $style1
  $HTML += "<h3>$($title)</h3>" 
  $HTML += "<h4>$($msg)</h4>"
  $HTML += "<h4>($($count)) $($countMsg) </h4>"
  $HTML += "<h4>Script Started: $($StartTime)</h4>"
  $HTML += New-HTMLTable -InputObject $($result)
  $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

  $emailParams = @{
    to         = 'sean.connealy@sonymusic.com'
    from       = 'Posh Alerts poshalerts@sonymusic.com'
    subject    = $title
    smtpserver = 'ussmtp01.bmg.bagint.com'
    body       = ($HTML | Out-String)
    bodyashtml = $true
  }

  Send-MailMessage @emailParams
}
#requires -Version 2 -Modules CorpApps, HTMLTable
#requires -PSSnapin Quest.ActiveRoles.ADManagement
Add-PSSnapin -Name Quest.ActiveRoles.ADManagement 

# vars
$StartTime = Get-Date -Format G
$title = 'Disable Inactive Computers'
$countMsg = 'Computer Accounts Disabled.'
$days = '30'
$numComps = '60'
$Currentdate = Get-Date
$targetOu = 'bmg.bagint.com/USA/GBL/WST/Disabled'
#$currentDir = Get-ScriptDirectory
$CSV = "c:\temp\inactive_computers-$($Currentdate).csv"

# params
  $emailParams = @{
    To          = 'sean.connealy@sonymusic.com'
    From        = 'Posh Alerts poshalerts@sonymusic.com'
    Subject     = $title
    SmtpServer = 'ussmtp01.bmg.bagint.com'
    BodyAsHTML  = $true
  }

$QADParams = @{
  SizeLimit                        = '0'
  PageSize                         = '2000'
  DontUseDefaultIncludedProperties = $true
  IncludedProperties               = @('Name', 'LastLogonTimeStamp', 'OSName', 'ParentContainerDN')
  SearchRoot                       = @('bmg.bagint.com/USA/GBL/WST/Windows7', 'bmg.bagint.com/USA/GBL/WST/XP')
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
$query = Get-QADComputer @QADParams | Select-Object name, osname, lastlogontimestamp, parentcontainer -ErrorAction 0
$query = $query | Where-Object { $_.LastLogonTimeStamp -ne $Null -and ($Currentdate-$_.LastLogonTimeStamp).Days -gt $days -and $_.parentcontainer -notlike '*Exclude*'} 

$count = $query.Count

$result = New-Object System.Collections.ArrayList

if (($query) -and $query.Count -lt $numComps) {
  foreach ($q in $query){
    $info = [pscustomobject]@{
      'Computer'   = $q.Name.ToUpper()
      'OS'         = $q.OSName
      'target OU'  = $targetOu.Replace('bmg.bagint.com/','')
    }

    Disable-QADComputer -Identity $q.Name -ErrorAction 0 -WhatIf
    Move-QADObject -Identity $q.Name -To $targetOu -ErrorAction 0 -WhatIf

    $result.Add($info) | Out-Null  
  }

  $HTML = New-HTMLHead -title $title -style $style1
  $HTML += "<h3>$($title)</h3>"
  $HTML += "<h4>Days Inactive: $($days)</h4>"
  $HTML += "<h4>($($count)) $($countMsg)</h4>"
  $HTML += "<h4>Script Started: $($StartTime))</h4>"
  $HTML += New-HTMLTable -InputObject $($result)
  $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

  Send-MailMessage @emailParams -Body ($HTML | Out-String)
}
else {
  $HTML = New-HTMLHead -title $title -style $style1
  $HTML += "<h3>$($title)</h3>"
  $HTML += "<h4>Days Inactive: $($days)</h4>"
  $HTML += "<h4>($($count)) $($countMsg)</h4>"
  $HTML += '<h4>Please See Attachment.</h4>'

  $query | Export-Csv $CSV -NoTypeInformation
  Send-MailMessage @emailParams -Body ($HTML | Out-String) -Attachments $CSV
}
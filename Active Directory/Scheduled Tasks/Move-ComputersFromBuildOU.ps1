#requires -Modules HTMLTable
#requires -Version 2
#requires -PSSnapin Quest.ActiveRoles.ADManagement
Add-PSSnapin -Name Quest.ActiveRoles.ADManagement 

# vars
$title     = 'Move computer objects from build OUs'
$StartTime = Get-Date -Format G
$targetOU  = 'bmg.bagint.com/USA/GBL/WST/Windows7'
$msg       = 'Source OUs: /USA/GBL/W7Build & /Computers'
$countMsg  = 'Computer objects moved.'

# params
$QADParams = @{
  SizeLimit                        = '0'
  PageSize                         = '2000'
  DontUseDefaultIncludedProperties = $true
  IncludedProperties               = @('Name', 'SAMAccountName', 'ParentContainer')
  SearchRoot                       = @('bmg.bagint.com/USA/GBL/W7Build', 'bmg.bagint.com/Computers')
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

$query = Get-QADComputer @QADParams | 
Where-Object {
  $_.OSVersion -like '6.1*' `
  -and $_.computername -like 'USD*' `
  -or  $_.computername -like 'USL*' `
  -or  $_.computername -like 'ULL*' `
  -or  $_.computername -like 'PAR*' 
}

$result = New-Object System.Collections.ArrayList

# Main Loop
if ($query -ne $null) {
  foreach ($comp in $query){
    $info = [pscustomobject]@{
      'Computer' = $comp.Name.ToUpper()
      'Source OU'      = $comp.ParentContainer.Replace('bmg.bagint.com/','')
      'Target OU' = $targetOU.Replace('bmg.bagint.com/','')
    }

    Move-QADObject -Identity $comp.SamAccountName -To $targetOU -WhatIf

    $result.Add($info) | Out-Null
  }

  $count = $result.Count

  $HTML = New-HTMLHead -title $title -style $style1
  $HTML += "<h3>$($title)</h3>"
  $HTML += "<h4>$($msg)</h4>"
  $HTML += "<h4>($($count)) $($countMsg) </h4>"
  $HTML += "<h4>Script started: $($StartTime)</h4>"
  $HTML += New-HTMLTable -InputObject $($result)
  $HTML += "<h4>Script completed: $(Get-Date -Format G)</h4>" | Close-HTML

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

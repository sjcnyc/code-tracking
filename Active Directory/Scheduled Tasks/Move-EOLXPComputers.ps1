$StartTime = Get-Date -Format G
$title = 'Disable EOL XP objects'
$countMsg = 'EOL XP objects disabled.'
$targetOu = 'bmg.bagint.com/USA/GBL/WST/Disabled'

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
  IncludedProperties               = @('Name', 'SAMAccountName', 'ParentContainer')
  SearchRoot                       = @('bmg.bagint.com/USA')
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

$query = Get-QADComputer @QADPArams | 
Where-Object { $_.OSVersion -like '5.1*' -and $_.Computername -notlike 'USCULVWCON001' `
              -and $_.ParentContainer -notlike '*Disabled'  }

$count = $query.Count

$result = New-Object System.Collections.ArrayList

if ($query -ne $null) {
  foreach ($comp in $query){
    $info = [pscustomobject]@{
      'Computer'  = $comp.Name.ToUpper()
      'Source OU' = $comp.ParentContainer.Replace('bmg.bagint.com/','')
      'Target OU' = $targetOU.Replace('bmg.bagint.com/','')
    }

    Disable-QADComputer -Identity $comp.Name -ErrorAction 0 -WhatIf
    Move-QADObject -Identity $comp.Name -To $targetOu -ErrorAction 0 -WhatIf

    $result.Add($info) | Out-Null
  }

  $HTML = New-HTMLHead -title $title -style $style1
  $HTML += "<h3>$($title)</h3>"
  $HTML += "<h4>($($count)) $($countMsg)</h4>"
  $HTML += "<h4>Script Started: $($StartTime))</h4>"
  $HTML += New-HTMLTable -InputObject $($result)
  $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

  Send-MailMessage @emailParams -Body ($HTML | Out-String)

  }


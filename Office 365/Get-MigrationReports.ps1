Import-Module -Name pshtmltable
Import-Module -Name ConnectO365

Connect-O365 -Account 'sean.connealy.admin@SonyMusicEntertainment.onmicrosoft.com' -Exchange -Persist

# vars
  $StartTime = Get-Date -Format G
  $title = 'Mailbox Migration Report'
  $countMsg = 'Mailboxes InProgress'
  $numberofMBX = 10
  $Currentdate = get-date -Format ddMMyyyy-hMMss
  $CSV = "C:\temp\MigrationReport-$($Currentdate).csv"

  $emailParams = @{
    To = 'sean.connealy@sonymusic.com'<#,'Alex.Moldoveanu@sonymusic.com','Rohan.Simpson@sonymusic.com','Pete.Elgar@sonymusic.com','jorge.ocampo.peak@sonymusic.com','brian.lynch@sonymusic.com','ingo.kresse@sonymusic.com','marion.raabe@sonymusic.com','Dustin.McClung@sonymusic.com','Andrew.Wong@sonymusic.com','simin.vaswani.citadelny@sonymusic.com','Robert.yaus@sonymusic.com','carol.paterno@sonymusic.com','thomas.ecker@sonymusicexternal.com','Alfredo.Torres.PEAK@sonymusic.com'#>
    From = 'Posh Alerts poshalerts@sonymusic.com'
    Subject = $title
    SmtpServer = 'ussmtp01.bmg.bagint.com'
    BodyAsHTML = $true
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

  $query = Get-moverequest -MoveStatus InProgress |
    Get-moverequeststatistics |
    Select-Object -Property Identity, Alias, DisplayName, PercentComplete, TotalMailboxSize, BatchName

  $count = $query.count

  $result = New-Object System.Collections.ArrayList

  if ($query.count -le $numberofMBX) {
    foreach ($q in $query) {
        $info = [pscustomobject]@{
            'Identity' = $q.Identity
            'Alias' = $q.Alias
            'DisplayName' = $q.DisplayName
            'PercentComplete' = $q.PercentComplete
            'TotalMailboxSize' = $q.TotalMailboxSize
            'BatchName' = $q.BatchName
        }

        $null = $result.Add($info)
    }

    $HTML = New-HTMLHead -title $title -style $style1
    $HTML += "<h3>$($title)</h3>"
    $HTML += "<h4>($($count)) $($countMsg)</h4>"
    $HTML += "<h4>Script Started: $($StartTime)</h4>"
    $HTML += New-HTMLTable -InputObject $($result)
    $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

    Send-MailMessage @emailParams -Body ($HTML | Out-String)
    }
    else {
      $HTML = New-HTMLHead -title $title -style $style1
      $HTML += "<h3>$($title)</h3>"
      $HTML += "<h4>($($count)) $($countMsg)</h4>"
      $HTML += "<h4>Script Started: $($StartTime)</h4>"
      $HTML += '<h3>See Attached .csv.</h3>'
      $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

      $query | Export-Csv $CSV -NoTypeInformation
      Send-MailMessage @emailParams -Body ($HTML | Out-String) -Attachments $CSV
    }

Connect-O365 -Close
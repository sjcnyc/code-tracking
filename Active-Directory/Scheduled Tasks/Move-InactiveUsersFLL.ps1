#requires -Modules HTMLTable
#requires -Version 2
#requires -PSSnapin Quest.ActiveRoles.ADManagement

Add-PSSnapin -Name Quest.ActiveRoles.ADManagement

# vars
$StartTime   = Get-Date -Format G
$title       = 'FLL Disable Inactive User Accounts.'
$countMsg    = 'FLL User Accounts Disabled.'
$days        = '30'
$Currentdate = Get-Date
$targetOu    = 'bmg.bagint.com/FLL/LARO/USR/Disabled'

# params
$QADParams = @{
    SizeLimit                        = '0'
    PageSize                         = '2000'
    DontUseDefaultIncludedProperties = $true
    IncludedProperties               = @('Name', 'LastLogonTimeStamp', 'SamAccountName', 'ParentContainer')
    SearchRoot                       = @('bmg.bagint.com/FLL/LARO/USR/BHILL', 'bmg.bagint.com/FLL/LARO/USR/Employees', 'bmg.bagint.com/FLL/LARO/USR/Non Employee Users')
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
$query = Get-QADUser @QADParams | Select-Object -Property Name, LastLogonTimeStamp, SamAccountName, ParentContainer
$query = $query | Where-Object { $_.LastLogonTimeStamp -ne $Null -and ($Currentdate - $_.LastLogonTimeStamp).Days -gt $days }

$result = New-Object System.Collections.ArrayList

if ($query) {
    foreach ($q in $query) {
        $info = [pscustomobject]@{
            'Name'            = $q.Name
            'SAMAccountName'  = $q.SAMAccountName.ToUpper()
            'ParentContainer' = $q.ParentContainer.Replace('bmg.bagint.com/', '')
        }

        Disable-QADUser -Identity $q.SamAccountName -ErrorAction 0 -WhatIf
        Move-QADObject -Identity $q.SamAccountName -NewParentContainer $targetOu -WhatIf

        $null = $result.Add($info)
    }

    $count = $result.Count

    $HTML = New-HTMLHead -title $title -style $style1
    $HTML += "<h3>$($title)</h3>"
    $HTML += "<h4>Days Inactive: $($days).</h4>"
    $HTML += "<h4>($($count)) $($countMsg)</h4>"
    $HTML += "<h4>Script Started: $($StartTime)</h4>"
    $HTML += New-HTMLTable -InputObject $($result)
    $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

    $emailParams = @{
        To         = 'sean.connealy@sonymusic.com'
        From       = 'Posh Alerts poshalerts@sonymusic.com'
        Subject    = $title
        SmtpServer = 'ussmtp01.bmg.bagint.com'
        BODY       = ($HTML | Out-String)
        BodyAsHTML = $true
    }
    Send-MailMessage @emailParams
}
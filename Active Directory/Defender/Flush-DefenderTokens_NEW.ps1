edge#requires -Modules PSHTMLTable

Add-PSSnapin -Name Quest.ActiveRoles.ADManagement
Add-PSSnapin -Name Quest.Defender.AdminTools

# vars
$StartTime = Get-Date -Format G
$title = 'Flush Unused Defender Tokens'
$countMsg = 'Number of tokens: '

# params
$QADParams = @{
    SizeLimit            = '0'
    PageSize             = '2000'
    IncludeAllProperties = $true
    Type                 = 'defender-tokenClass'
    SearchRoot           = @('OU=Defender,DC=bmg,DC=bagint,DC=com')
}

$style1 = '<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 8pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #666666;}
  h4 {font-size: 8pt;}
  h5 {font-size: 8pt; margin: 0 0 0 0;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#eeeeee;background-color:#333333;border:1px solid black;padding:4px;}
  td {padding:4px; border:1px solid black;}
  .odd { background-color:#ffffff; }
  .even { background-color:#CFCFCF; }
</style>'

$tokens = (Get-QADObject @QADParams).Where{ $_.'defender-tokenUsersDNs' -eq $null -and $_.name -like 'PDWIN*' -or $_.name -like 'PDIPN*' }

$result = New-Object System.Collections.ArrayList

if ($tokens) {
    foreach ($token in $tokens) {
        $info = [pscustomobject]@{
            'Name'        = $token.Name
            'Description' = $token.Description
        }
        # Reset-DefenderToken -TokenCommonName $token.Name
        Remove-QADObject -Identity $token.Name -Force -WhatIf
        $null = $result.Add($info)
    }
    $count        = $result.Count
    $store        = Get-DefenderLicense
    $percent      = 0
    $licensetype  = $store.LicenseType
    $userassigned = $store.AssignedUsers
    $usertotal    = $store.TotalUsers
    $tokensfree   = ($usertotal - $userassigned)
    $percent      = $percent + ($userassigned / $usertotal) * 100
    $percent      = '{0:N2}' -f ($percent)

    $HTML = New-HTMLHead -title $title -style $style1
    $HTML += "<h3>$($title)</h3>"
    $HTML += "<h4>$($countMsg) ($($count))</h4>"
    $HTML += "<h4>Script Started: $($StartTime)</h4>"
    $HTML += New-HTMLTable -InputObject $($result)
    $HTML += '<h5>&nbsp;</h5>'
    $HTML += "<h5>$($percent)% of licenses used.</h5>"
    $HTML += "<h5>$($tokensfree) tokens left for distribution.</h5>"
    $HTML += "<h5>$($licensetype) License has $userassigned users assigned.</h5>"
    $HTML += "<h5>The total number of Licenses: $($usertotal).</h5>"
    $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

    $emailParams = @{
        To         = 'sean.connealy@sonymusic.com'
        From       = 'Posh Alerts poshalerts@sonymusic.com'
        Subject    = $title
        SmtpServer = 'ussmtp01.bmg.bagint.com'
        Body       = ($HTML | Out-String)
        BodyAsHTML = $true
    }
    Send-MailMessage @emailParams
}
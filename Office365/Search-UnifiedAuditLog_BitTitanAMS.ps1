#requires -Modules PSHTMLTable

$style1 = '<style>
  body {color:#666666;font-family:Calibri,Tahoma,arial,verdana;font-size: 11pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #666666;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#eeeeee;background-color:#666666;border:1px solid black;padding:4px;}
  td {padding:4px; border:1px solid black;}
  .odd { background-color:#ffffff; }
  .even { background-color:#E5E7E9; }
</style>'

$CSV = "c:\temp\BitTitan_Audit-$((get-date).ToString("yyyMMdd")).csv"

$emailParams = @{
    to         = 'sean.connealy@sonymusic.com'
    from       = 'Posh Alerts poshalerts@sonymusic.com'
    subject    = "BitTitan AMS log review"
    smtpserver = 'ussmtp01.bmg.bagint.com'
    bodyashtml = $true
}

$startDate = (get-date).AddDays(-2).ToString("MM/dd/yyyy")
$endDate   = (get-date).AddDays(1).ToString("MM/dd/yyyy")

$results =
Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -UserIds "BitTitan*" -Operations "PasswordLogonInitialAuthUsingPassword" -ResultSize 5000 |
Select-Object * -ExpandProperty AuditData | ConvertFrom-Json

$PSArrayList = New-Object -TypeName System.Collections.ArrayList

$IPArray =
@(
    "23.29.98.196",
    "4.14.236.226",
    "84.17.163.36",
    "2603:10a6:0:6:cafe::c6",
    "2603:10a6:207:2:cafe::a6",
    "2603:10a6:207:2:cafe::a7",
    "2603:10a6:0:6:cafe::fd",
    "2a01:111:e400:7a2f:cafe::9a"
)

foreach ($result in $results) {
    $result1 = if ($result.ClientIP -in $IPArray ) {'Passed'} else {'Failed'}

    $PSObj = [pscustomobject]@{
        'UserID'       = $result.UserId
        'CreationTime' = $result.CreationTime
        'Operation'    = $result.Operation
        'ClientIP'     = $result.ClientIP
        'Result'       = $result1
    }
    $null = $PSArrayList.Add($PSObj)
}

$params1 = @{
    ScriptBlock = {$args[0] -gt 0}
}

$Failed = $PSArrayList | Select-Object * | Where-Object {$_.Result -eq 'Failed'}

$passedCount = ($PSArrayList | Select-Object * | Where-Object {$_.Result -eq 'Passed'}).Count
$failedCount = ($Failed.Result).Count
$totalCount  = $PSArrayList.Count

$summaryTable = [PSCustomObject] @{
    "Passed Count" = $passedCount
    "Failed Count" = $failedCount
    "Total Count"  = $totalCount
    }

    $summaryTable = $summaryTable | New-HTMLTable |
    Add-HTMLTableColor -Column "Failed Count" -AttrValue "background-color:#ffb3b3;" @params1 |
    Add-HTMLTableColor -Column "Passed Count" -AttrValue "background-color:#c6ffb3;" @params1

if (![string]::IsNullOrEmpty($PSArrayList)) {

        $params = @{ ScriptBlock = {$args[0] -eq $args[1]}}

        $HTML = New-HTMLHead -title "BitTitan AMS log review" -style $style1
        $HTML += "<h3>BitTitan AMS Log Review</h3>"
        $HTML += $summaryTable
        if ($Failed)
        {
            $HTML += "<br>"
            $HTML += $Failed| New-HTMLTable | Add-HTMLTableColor -Argument 'Failed' -Column "Result" -AttrValue "background-color:#ffb3b3;" @params
        }
        $HTML += "<h4>Please See Attachment</h4>"
        $HTML += "<h4>Script completed: $(Get-Date -Format G)</h4>" | Close-HTML
        $results | Export-Csv $CSV -NoTypeInformation
        Send-MailMessage @emailParams -Body ($HTML | Out-String) -Attachments $CSV
}
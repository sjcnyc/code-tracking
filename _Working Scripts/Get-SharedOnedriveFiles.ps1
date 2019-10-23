using namespace System.Collections.Generic
function Get-SharedOnedriveFiles {
  param (
    $UserPrincipalName,
    $UserEmail
  )

  $Style1 =
  '<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
</style>'

  $UserList = [List[PSObject]]::new()

  $startDate = (get-date).AddDays(-30).ToString("MM/dd/yyyy")
  $endDate   = (get-date).AddDays(1).ToString("MM/dd/yyyy")

  Try {

    $results =
    Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -Operations "SharingSet" -UserIds $UserPrincipalName |
    Select-Object * -ExpandProperty AuditData |
    ConvertFrom-Json

    foreach ($result in $results) {

      $PSObj = [pscustomobject]@{
        'UserID'         = $result.UserId
        'CreationTime'   = $result.CreationTime
        'Workload'       = $result.Workload
        'File'           = $result.ObjectID -replace "https://sonymusicentertainment-my.sharepoint.com/personal/", ""
        'SourceFileName' = $result.SourceFileName
        'Target'         = $result.TargetUserOrGroupName
      }
      [void]$UserList.Add($PSObj)
    }

    $UserList = $UserList | Where-Object { $_.Target -ne "Limited Access System Group" } | Sort-Object -Property File -Unique

    $HTML = New-HTMLHead -title "OneDrive Recently Shared Files" -style $Style1
    $HTML += "<h3 style='color:red; font-style:bold;'><i>Disclaimer: OneDrive should not contain Confidential or Secret Data</i></h3>"
    $HTML += "<h3>Please see your recently shared OneDrive files below:</h3>"
    $HTML += "<h3 style='font-style:italic;'>To view the full list or remove permissions please follow the below steps:</h3>"
    $HTML += "<ol style='font-style:italic;'>"
    $HTML += "<li>Right click on the OneDrive Icon</il>"
    $HTML += "<li>Click ""View Online""</li>"
    $HTML += "<li>On the left panel locate ""Shared""</li>"
    $HTML += "<li>On top select ""Shared by you""</li>"
    $HTML += "</ol>"
    $HTML += "<h3><i>For any questions or assistance needed please contact the service desk at service.desk@sonymusic.com</i></h3>"
    $HTML += New-HTMLTable -inputObject $($UserList | Select-Object CreationTime, Workload, File, Target | Where-Object { $_.Workload -eq "OneDrive" })
    $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

    $EmailParams = @{
      to         = 'sconnea@sonymusic.com' #, $UserEmail
      from       = 'PwSh Alerts pwshalerts@sonymusic.com'
      subject    = 'OneDrive Recently Shared Files'
      smtpserver = 'cmailsony.servicemail24.de'
      Body       = ($HTML | Out-String)
      BodyAsHTML = $true
    }

    Send-MailMessage @EmailParams
  }
  catch {
    $error.message
  }
}

#Connect-MsolService

#$users = (Get-MsolUser -MaxResults 100 | Select-Object).UserPrincipalName

$users =
@"
brian.lynch@sonymusic.com
"@ -split [environment]::NewLine

foreach ($user in $users) {

  Get-SharedOnedriveFiles -UserPrincipalName $user -UserEmail $user
}
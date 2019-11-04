using namespace System.Collections.Generic

Import-Module ExchangeOnline

$AllUsers = [List[PSObject]]::new()

try {
  Write-Output "Retrieving runbook credential object"
  $Credential = Get-AutomationPSCredential -Name 'T2_Cloud_Cred'
  Write-Output "Credentials retrieved"
}
catch {
  Write-Error "Failed to retrieve runbook credentials" -ErrorAction Continue
  Write-Error $_ -ErrorAction Stop
}

try {
  Write-Output "Connecting to AzureAD"
  Connect-AzureAD -Credential $Credential -ErrorAction SilentlyContinue
  Write-Output "Connectiong to Exchange Online"
  Connect-EXOService -Credential $Credential
}
catch {
  Write-Error $_ -ErrorAction Stop
}

$Az_UserGroup = "5fe98e81-c56d-45b9-b344-9a75de2f2586" # AZ_OneDrivePilot security group

$Az_GroupMemebersUPN = (Get-AzureADGroupMember -ObjectId $Az_UserGroup).UserPrincipalName

#Write-Output $Az_GroupMemebersUPN

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

  $StartDate = (get-date).AddDays(-30).ToString("MM/dd/yyyy")
  $EndDate = (get-date).AddDays(1).ToString("MM/dd/yyyy")

  Try {

    $Results =
    Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -Operations "SharingSet" -UserIds $UserPrincipalName | Select-Object * -ExpandProperty AuditData | ConvertFrom-Json

    foreach ($Result in $Results) {

      $Target = if ($Result.TargetUserOrGroupName -eq "Limited Access System Group") {
        "SharePoint Group" 
      } 
      elseif ($Result.TargetUserOrGroupName -like "*SharingLinks*") {
        "SharingLInks"
      }
      else {
        $Result.TargetUserOrGroupName
      }

      $PSObj = [pscustomobject]@{
        'UserID'         = $Result.UserId
        'CreationTime'   = $Result.CreationTime
        'Workload'       = $Result.Workload
        'File'           = $Result.ObjectID -replace "https://sonymusicentertainment-my.sharepoint.com/personal/", ""
        'SourceFileName' = $Result.SourceFileName
        'Target'         = $Target
      }
      [void]$UserList.Add($PSObj)
    }

    $UserList = $UserList | Sort-Object -Property File -Unique

    if ($null -ne $UserList) {

      # Write-Output $UserList

      $HTML = New-HTMLHead -title "OneDrive Recently Shared Files" -style $Style1
      $HTML += "<h3 style='color:red; font-style:bold;'><i>Notice: OneDrive is not yet approved for storage of data classified as Secret</i></h3>"
      $HTML += "<h3>Please see your recently shared OneDrive files below:</h3>"
      $HTML += "<h3 style='font-style:italic;'>To view the full list or remove permissions please follow the steps below:</h3>"
      $HTML += "<ol style='font-style:italic;'>"
      $HTML += "<li>Right click on the OneDrive Icon</il>"
      $HTML += "<li>Click ""View Online""</li>"
      $HTML += "<li>On the left panel locate ""Shared""</li>"
      $HTML += "<li>On top select ""Shared by me""</li>"
      $HTML += "</ol>"
      $HTML += "<h3 style='font-style:italic;'>Manage access or stop sharing a file or folder from the Shared By Me view:</h3>"
      $HTML += "<ol style='font-style:italic;'>"
      $HTML += "<li>To manage access or stop sharing the file or folder, select an item, and then select Manage access near the top of the page.</il>"
      $HTML += "<li>To stop sharing with everyone, near the top of the Manage Access pane, select Stop sharing.</il>"
      $HTML += "<li>To stop sharing with one person, select the dropdown list, and then select Stop sharing.</il>"
      $HTML += "<li>To change the person's permissions, select the dropdown list, and then select Can View or Can Edit.</il>"
      $HTML += "</ol>"
      $HTML += "<h3><i>For any questions or assistance needed please contact the service desk at service.desk@sonymusic.com</i></h3>"
      $HTML += New-HTMLTable -inputObject $($UserList | Select-Object CreationTime, Workload, File, Target | Where-Object { $_.Workload -eq "OneDrive" })
      $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

      $EmailParams = @{
        To         = 'sconnea@sonymusic.com', $UserEmail
        From       = 'PwSh Alerts pwshalerts@sonymusic.com'
        Subject    = 'OneDrive Recently Shared Files!!'
        SmtpServer = 'smtp.office365.com'
        Port       = 587
        UseSsl     = $true
        Body       = ($HTML | Out-String)
        BodyAsHTML = $true
        Credential = $Credential
      }

      Send-MailMessage @EmailParams
    }
    else { Write-Output "No data" }
  }
  catch [Microsoft.PowerShell.Commands.WriteErrorException] {
    Write-Error $error.message
  }
}

#Connect-MsolService

#$users = (Get-MsolUser -MaxResults 100 | Select-Object).UserPrincipalName

<# $Users =
@"
brian.lynch@sonymusic.com
"@ -split [environment]::NewLine #>

foreach ($userUpn in $Az_GroupMemebersUPN) {
  Get-SharedOnedriveFiles -UserPrincipalName $userUpn -UserEmail $userUpn
}
function Remove-UsersFromAdGroup {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess = $true)]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $GroupName,

    [System.Management.Automation.SwitchParameter]
    $SendEmail
  )
  $cred = Get-AutomationPSCredential -Name 'T2_Cred'
  $StartTime = Get-Date -Format G

  $Style1 =
  '<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 10pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
  </style>'

  $PSArrayList = New-Object System.Collections.ArrayList
  $Users = Get-ADGroup -Identity $GroupName -Credential $cred | Get-ADGroupMember -Recursive -Credential $cred
  $Count = $users.Count
  try {
    if ($null -eq $users) {
      $HTML = New-HTMLHead -title "Remove Users From $($GroupName)" -style $Style1
      $HTML += "<h3>Remove Users From $($GroupName)</h3>"
      $HTML += "<h4>Azure Hybrid Runbook Worker: Tier-2</h4>"
      $HTML += "<h4>Script started: $($StartTime)</h4>"
      $HTML += "<h4>Users Removed: 0</h4>"
      $HTML += "<h4>Script completed: $(Get-Date -Format G)</h4>" | Close-HTML
    }
    else {
      foreach ($User in $Users) {
        $U = Get-ADUser $User.SamAccountName -Credential $cred | Select-Object Name, SamAccountName, UserPrincipalName
        $PSObj = [pscustomobject]@{
          User           = $U.Name
          UPN            = $U.UserPrincipalName
          SamAccountName = $U.SamAccountName
          Group          = $GroupName
        }
        [void]$PSArrayList.Add($PSObj)
      }
      Get-AdGroup $Groupname | Set-ADGroup -clear member -Credential $cred

      $HTML = New-HTMLHead -title "Remove Users From $($GroupName)" -style $Style1
      $HTML += "<h3>Remove Users From $($GroupName)</h3>"
      $HTML += "<h4>Azure Hybrid Runbook Worker: Tier-2</h4>"
      $HTML += "<h4>Script started: $($StartTime)</h4>"
      $HTML += New-HTMLTable -InputObject $($PSArrayList)
      $HTML += "<h4>Users Removed: $($Count)</h4>"
      $HTML += "<h4>Script completed: $(Get-Date -Format G)</h4>" | Close-HTML
    }
    if ($SendEmail) {
      $EmailParams = @{
        To         = "sean.connealy@sonymusic.com", "brian.lynch@sonymusic.com", "Alex.Moldoveanu@sonymusic.com", "global.ops.team@sonymusic.com"
        From       = 'PwSh Alerts pwshalerts@sonymusic.com'
        Subject    = "Remove Users From $($GroupName)"
        SmtpServer = 'cmailsony.servicemail24.de'
        Body       = ($HTML | Out-String)
        BodyAsHTML = $true
      }
      Send-MailMessage @EmailParams
    }
  }
  catch {
    $_.Exception.Message
  }
}

Remove-UsersFromAdGroup -GroupName "Okta_EnrollMFA_OffNet" -SendEmail
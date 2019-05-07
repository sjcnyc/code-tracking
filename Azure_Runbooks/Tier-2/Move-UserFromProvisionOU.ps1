function ConvertFrom-DN {
  param([string]$DN = (Throw "$DN is required!"))
  foreach ( $item in ($DN.replace('\,', '~').split(','))) {
    switch -regex ($item.TrimStart().Substring(0, 3)) {
      'CN=' {
        $CN = '/' + $item.replace('CN=', '')
        continue
      }
      'OU=' {
        $ou += , $item.replace('OU=', '')
        $ou += '/'
        continue
      }
      'DC=' {
        $DC += $item.replace('DC=', '')
        $DC += '.'
        continue
      }
    }
  }
  $canoincal = @()
  $canoincal = $DC.Substring(0, $DC.length - 1)
  for ($i = $ou.count; $i -ge 0; $i -- ) {
    $canoincal += $ou[$i]
  }

  # return only OU path
  return $canoincal.Substring($DC.length - 1)

  # return full parten container path
  # return $canoincal
} #

function Move-UserFromProvisionOU {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess = $true)]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $SourceOU,

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
  $Users = Get-ADUser -SearchBase $SourceOU -Filter * -Properties * -Credential $cred | 
  Where-Object { $null -ne $_.extensionAttribute1 } | Select-Object Name, SamAccountName, UserPrincipalName, distinguishedname, extensionAttribute1
  $Count = 0
  try {
    foreach ($User in $Users) {
      $Count ++
      $ParentContainer = ConvertFrom-DN -DN $User.extensionAttribute1
      $PSObj = [pscustomobject]@{
        User           = $User.Name
        #  UPN               = $User.UserPrincipalName
        SamAccountName = $User.SamAccountName
        DestOU         = $ParentContainer
      }
      [void]$PSArrayList.Add($PSObj)
      Move-ADObject -Identity $User.distinguishedname -TargetPath $User.extensionAttribute1 -Credential $cred
      Write-Output "Moving User: $($User.distinguishedname) to: $($ParentContainer)"
    }
    
    if ($Count -gt 0) {
      $HTML = New-HTMLHead -title "Move Users From Staging to Production" -style $Style1
      $HTML += "<h3>Move Users From Staging to Production</h3>"
      $HTML += "<h4>Azure Hybrid Runbook Worker: Tier-2</h4>"
      $HTML += "<h4>Script started: $($StartTime)</h4>"
      $HTML += New-HTMLTable -InputObject $($PSArrayList)
      $HTML += "<h4>Users Moved: $($Count)</h4>"
      $HTML += "<h4>Script completed: $(Get-Date -Format G)</h4>" | Close-HTML

      if ($SendEmail) {
        $EmailParams = @{
          To         = "sean.connealy@sonymusic.com", "Access.Control@sonymusic.com"
          From       = 'PwSh Alerts pwshalerts@sonymusic.com'
          Subject    = "Move Users From Staging to Production"
          SmtpServer = 'cmailsony.servicemail24.de'
          Body       = ($HTML | Out-String)
          BodyAsHTML = $true
        }
        Send-MailMessage @EmailParams
      }
    }
  }
  catch {
    $_.Exception.Message
  }
}

Move-UserFromProvisionOU -SourceOU "OU=NewSync,OU=DomainJoin,OU=USA,OU=NA,OU=Provision,OU=STG,OU=Tier-2,DC=me,DC=sonymusic,DC=com" -SendEmail
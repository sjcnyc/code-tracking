using namespace System.Collections.Generic

$PSList = [List[psobject]]::new()
$DaysInactive = '90'
$Date = (Get-Date -f yyyy-MM-dd)
$CSVFile = "C:\Temp\Computer_Objects_Inactive_90_Days_$($Date).csv"
$ScriptStartTime = (Get-Date -Format G)
$InactiveComputerCount = 0


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

$searchADAccountSplat = @{
  ComputersOnly   = $true
  Server          = 'me.sonymusic.com'
  AccountInactive = $true
  TimeSpan        = $DaysInactive
  ErrorAction     = 0
  SearchBase     = "OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
}
$InactiveComputers = (Search-ADAccount @searchADAccountSplat).Where{ $null -ne $_.LastLogonDate }

foreach ($Computer in $InactiveComputers) {
  try {

    $InactiveComputerCount ++

    $PSComputerObject =
    [PSCustomObject]@{
      Name              = $Computer.Name
      DistinguishedName = $Computer.DistinguishedName
      ObjectClass       = $Computer.ObjectClass
      SamAccountName    = $Computer.SamAccountName
      Enabled           = $Computer.Enabled
      LastLogonDate     = $Computer.LastLogonDate
    }
    [void]$PSList.Add($PSComputerObject)

    $disableADAccountSplat = @{
      Server      = 'me.sonymusic.com'
      WhatIf      = $true
      ErrorAction = 0
      Identity    = $Computer.DistinguishedName
    }
    #Disable-ADAccount @disableADAccountSplat

    $moveADObjectSplat = @{
      WhatIf      = $true
      Server      = 'me.sonymusic.com'
      ErrorAction = 0
      TargetPath  = "OU=Workstations,OU=Deprovision,OU=STG,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
      Identity    = $Computer.DistinguishedName
    }
    #Move-ADObject @moveADObjectSplat
  }
  catch {
    Write-Output $_.Exception.Message
  }
}

$InfoBody = [pscustomobject]@{
  'Task'            = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'          = "Move Inactive Computer Objects"
  'Days Inactive'   = $DaysInactive
  'Computers Total' = $InactiveComputerCount
}

$HTML = New-HTMLHead -title "Move Inactive Computer Objects" -style $Style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)

if ($InactiveComputerCount -gt 1) {
  $PSList | Export-Csv $CSVFile -NoTypeInformation
  $HTML += "<h4>See Attached CSV Report(s)</h4>"
}


$HTML += "<h4>Script Started: $($ScriptStartTime)</h4>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$EmailParams = @{
  To          = "sconnea@sonymusic.com"
  From        = 'PwSh Alerts poshalerts@sonymusic.com'
  Subject     = "Move Inactive Computer Objects"
  SmtpServer  = 'cmailsony.servicemail24.de'
  Body        = ($HTML | Out-String)
  BodyAsHTML  = $true
  Attachments = $CSVFile
}

Send-MailMessage @EmailParams
Start-Sleep -Seconds 5
Remove-Item $CSVFile
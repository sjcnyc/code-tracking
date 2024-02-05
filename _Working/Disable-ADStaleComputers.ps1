function ConvertFrom-DN {
  param([string]$DN)
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
  $canoincal = $DC.Substring(0, $DC.length - 1)
  for ($i = $ou.count; $i -ge 0; $i -- ) {
    $canoincal += $ou[$i]
  }
  if ($null -eq $CN) {
    # $canoincal += $CN.ToString().replace('~', ',')
  }
  return $canoincal
}
function Disable-ADStaleComputers {

  #Requires -version 3
  #Requires -modules ActiveDirectory

  [CmdletBinding(SupportsShouldProcess)]
  Param(
    [parameter(Mandatory, Position = 1)]
    [ValidateScript( { Get-ADDomain -Server $_ })]
    [String]$Domain,

    [parameter(Mandatory, Position = 2)]
    [ValidateSet(60, 90, 120, 150, 180)]
    [Int32]$StaleThreshold,

    [switch]
    $Disable
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

  $DaysAgo = (Get-Date).AddDays(-$StaleThreshold)
  $Date = (get-date -f yyyy-MM-dd)
  $CSVFile = "C:\temp\StaleComputerAccounts_$($StaleThreshold)_Days_$($Date).csv"

  $ADObjectSplat = @{
    Filter     = { LastLogonTimeSTamp -lt $DaysAgo }
    Properties = 'PwdLastSet', 'LastLogonTimeStamp', 'Description', 'distinguishedName', 'SamAccountName', 'CanonicalName', 'Name'
    Server     = $Domain
  }

  $stdous = Get-ADOrganizationalUnit -filter * | Where-Object { $_.distinguishedname -like "OU=Win10,OU=Workstations*Tier-2*" -or $_.distinguishedname -like "OU=Mac,OU=Workstations*Tier-2*" }

  $StaleAccounts = foreach ($stdou in $stdous) {
    Get-ADComputer @ADObjectSplat -SearchBase $stdou.distinguishedName
  }

  if ($Disable) {

    $PSArrayList =
    foreach ($StaleAccount in $StaleAccounts) {

      #Disable the computer account
      #  Set-ADComputer -Identity $StaleAccount -Enabled $false -Server $Domain

      #Move the disabled computer account
      #  Move-ADObject -Identity $StaleAccount -TargetPath $TargetOu -Server $Domain

      [pscustomobject][ordered]@{
          Name               = $StaleAccount.Name
          SamAccountName     = $StaleAccount.SamAccountName
          Distinguishedname  = $StaleAccount.DistinguishedName
          Description        = $StaleAccount.Description
          LastLogonTimeStamp = [datetime]::FromFileTime($StaleAccount.LastLogonTimeSTamp)
          PwdLastSet         = [datetime]::FromFileTime($StaleAccount.PwdLastSet)
          SourceOU           = $StaleAccount.CanonicalName -replace "me.sonymusic.com/", ""
      }
    }

    $InfoBody = [pscustomobject]@{
      'Task'                   = "PowerShell Universal Job"
      'Action'                 = "Disable & Move ME AD Computer Objects"
      'Threshold'              = "$($StaleThreshold) Days"
      #'Source Ou'              = (ConvertFrom-DN -DN $SourceOu) -replace "me.sonymusic.com/", ""
      # 'Target Ou'              = (ConvertFrom-DN -DN $TargetOu) -replace "me.sonymusic.com/", ""
      "Total Computers" = $StaleAccounts.Count
    }

    $PSArrayList | Export-Csv $CSVFile -NoTypeInformation

    $HTML = New-HTMLHead -title "ME Stale Computer Account Cleanup Report" -style $Style1
    $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
    $HTML += "<h4>See Attached CSV Report</h4>"
    $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

    $EmailParams = @{
      To          = "sean.connealy@sonymusic.com"
      From        = 'Posh Alerts poshalerts@sonymusic.com'
      Subject     = "ME Stale Computer Account Cleanup Report"
      SmtpServer  = 'cmailsony.servicemail24.de'
      Body        = ($HTML | Out-String)
      BodyAsHTML  = $true
      Attachments = $CSVFile
    }

    Send-MailMessage @EmailParams
    Start-Sleep -Seconds 5
    Remove-Item $CSVFile
  }
}

$disableADStaleAccountSplat = @{
  Domain         = 'me.sonymusic.com'
  StaleThreshold = 120
  Disable        = $true
}

Disable-ADStaleComputers @disableADStaleAccountSplat
#git sync fix.  Stop syncing with multiple computers sean
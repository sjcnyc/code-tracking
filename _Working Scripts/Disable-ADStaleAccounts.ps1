using namespace System.Collections.Generic

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

function Disable-ADStaleAccounts {

  #Requires -modules ActiveDirectory

  [CmdletBinding(SupportsShouldProcess)]
  param(
    [parameter(Mandatory, Position = 1)]
    [ValidateScript( { Get-ADDomain -Server $_ })]
    [String]$Domain,

    [parameter(Mandatory, Position = 2)]
    [ValidateSet(60, 90, 120, 150, 180)]
    [Int32]$StaleThreshold,

    [parameter(Mandatory, Position = 3)]
    [ValidateSet("User", "Computer")]
    [String]$AccountType,

    [parameter(Position = 4)]
    [ValidateScript( { Get-ADOrganizationalUnit -Identity $_ -Server $Domain })]
    [String]$SourceOu,

    [parameter(Position = 5)]
    [ValidateScript( { Get-ADOrganizationalUnit -Identity $_ -Server $Domain })]
    [String]$TargetOu,

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
  $CSVFile = "C:\temp\StaleUserAccounts_$($StaleThreshold)Days_$($Date).csv"
  $PSList = [List[psobject]]::new()

  # Exclude below ous
  $Filter = [RegEx]'^*OU=LOH*|^*OU=Service*|^*OU=LOA*|^*OU=Test'

  $ADObjectSplat = @{
    Filter     = { (LastLogonTimeSTamp -lt $DaysAgo) }
    Properties = 'PwdLastSet', 'LastLogonTimeStamp', 'Description', 'distinguishedName', 'SamAccountName', 'CanonicalName', 'Name'
    Server     = $Domain
  }

  try {

    if ($SourceOU) {
      $StaleAccounts = &"Get-AD$AccountType" @ADObjectSplat -SearchBase $SourceOu | Where-Object { $_.distinguishedName -notmatch $Filter }
    }
    else {
      $StaleAccounts = &"Get-AD$AccountType" @ADObjectSplat | Where-Object { $_.distinguishedName -notmatch $Filter }
    }
    if ($Disable) {

      foreach ($StaleAccount in $StaleAccounts) {

        #&"Set-AD$AccountType" -Identity $StaleAccount -Enabled $false -Server $Domain

        #Move-ADObject -Identity $StaleAccount -TargetPath $TargetOu -Server $Domain

        $PSUserObj = [pscustomobject][ordered]@{
          Name               = $StaleAccount.Name
          SamAccountName     = $StaleAccount.SamAccountName
          DistinguishedName  = $StaleAccount.DistinguishedName
          Description        = $StaleAccount.Description
          LastLogonTimeStamp = [datetime]::FromFileTime($StaleAccount.LastLogonTimeSTamp)
          PwdLastSet         = [datetime]::FromFileTime($StaleAccount.PwdLastSet)
          SourceOU           = $StaleAccount.CanonicalName -replace "me.sonymusic.com/", ""
        }
        [void]$PSList.Add($PSUserObj)
      }

      $InfoBody = [pscustomobject]@{
        'Task'        = "Azure Hybrid Runbook Worker - Tier-2"
        'Action'      = "Disable & Move ME AD User Objects"
        'Threshold'   = "$($StaleThreshold) Days"
        'Source Ou'   = ConvertFrom-DN -DN $SourceOu -replace "me.sonymusic.com/", ""
        'Target Ou'   = ConvertFrom-DN -DN $TargetOu -replace "me.sonymusic.com", ""
        'Total Users' = $StaleAccounts.Count
      }

      $PSList | Export-Csv $CSVFile -NoTypeInformation

      $HTML = New-HTMLHead -title "ME Stale User Account Cleanup Report" -style $Style1
      $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
      $HTML += "<h4>See Attached CSV Report</h4>"
      $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

      $EmailParams = @{
        To          = "sean.connealy@sonymusic.com"
        From        = 'Posh Alerts poshalerts@sonymusic.com'
        Subject     = 'ME Stale User Account Cleanup Report'
        SmtpServer  = 'cmailsony.servicemail24.de'
        Body        = ($HTML | Out-String)
        BodyAsHTML  = $true
        Attachments = $CSVFile
      }

      Send-MailMessage @EmailParams
      Start-Sleep -Seconds 5
      Remove-Item $CSVFile
    }
    else {
      $StaleAccounts = $StaleAccounts | Select-Object -Property DistinguishedName, Name, Enabled, Description, @{Name = "PwdLastSet"; Expression = { [datetime]::FromFileTime($_.PwdLastSet) } }, @{Name = "LastLogonTimeStamp"; Expression = { [datetime]::FromFileTime($_.LastLogonTimeStamp) } }

      $StaleAccounts | Export-Csv C:\Temp\Stale_ME_User_accounts_00092.csv -NoTypeInformation
    }
  }
  catch {
    $_.Exception.Message
  }
}

$disableADStaleAccountsSplat = @{
    Domain         = 'me.sonymusic.com'
    StaleThreshold = 90
    AccountType    = 'User'
    SourceOu       = "OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
    Disable        = $true
    TargetOu       = "OU=Users,OU=Deprovision,OU=STG,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
}
Disable-ADStaleAccounts @disableADStaleAccountsSplat
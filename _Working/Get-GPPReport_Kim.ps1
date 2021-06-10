function Get-GPPReport {
  [CmdletBinding()]
  param (
    [parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
    [string[]]
    $GppName,

    [parameter(Mandatory = $true, Position = 1)]
    [string]$Path,

    [parameter(Mandatory = $true, Position = 2)]
    [string]$FileName
  )

  begin { $FileName = "$($FileName)_$(Get-Date -Format {MMddyyyy}).csv" }

  process {
    foreach ($Gpp in $GppName) {
      $Guid = (Get-GPO -Name $Gpp).Id
      [xml]$GpoXml = Get-GPOReport -Guid $Guid -ReportType Xml
      foreach ($Setting in $GpoXml.GPO.Computer.ExtensionData.Extension.LocalUsersAndGroups.Group) {
        foreach ($User in $Setting.properties.members.member.name) {
          $Output =
          foreach ($Computer in $Setting.Filters.FilterComputer.name) {
            [pscustomobject]@{
              GPO       = $GpoXml.GPO.Name
              GroupName = $Setting.properties.groupName
              Members   = $User
              Computer  = $Computer
            }
          }
          $Output | Export-Csv "$($Path)\$($FileName)" -NoTypeInformation -Append
        }
      }
    }
  }
  end {
    #$Output | Export-Csv "$($Path)\$($FileName)" -NoTypeInformation
  }
}

@'
T2_STD_NA_RDP-Access_Computer
T2_STD_LA_RDP-Access_Computer
T2_STD_EU_RDP-Access_Computer
T2_STD_AP_AUS_RDP-Access_Computer
T2_STD_Computer
'@ -split [environment]::NewLine | Get-GPPReport -path 'D:\Temp' -fileName 'GPPReport' -Verbose

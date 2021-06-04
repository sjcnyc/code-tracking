function Get-GPPReport {
  [CmdletBinding(SupportsShouldProcess = $True)]
  param (
    [parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
    [string[]]
    $gppName,

    [parameter(Mandatory = $true, Position = 1)]
    [string]
    $path,

    [parameter(Position = 2)]
    [string]
    $fileName
  )

  begin {
    $list = [System.Collections.Generic.List[PSObject]]::new()
    $fileName = "GPPReport_$(Get-Date -Format {MM-d-yyyy}).csv"
  }

  process {
    foreach ($gpp in $gppName) {
      $guid = (Get-GPO -Name $_).Id
      [xml]$gpoXml = Get-GPOReport -Guid $guid.Guid -ReportType Xml

      foreach ($setting in $gpoXml.GPO.Computer.ExtensionData.Extension.LocalUsersAndGroups.Group) {

        foreach ($user in $setting.properties.members.member.name) {

          foreach ($computer in $setting.Filters.FilterComputer.name) {
            [pscustomobject]@{
              GPO       = $gpoXml.GPO.Name
              GroupName = $setting.properties.groupName
              Members   = $user
              Computer  = $computer
            }
          }
        }
      }
      [void]$list.add($psObj)
    }
  }
  end { $List | Export-Csv "$($path)\$($fileName)" -NoTypeInformation -Append }

}

@'
T2_STD_NA_USA_GBL_RDP-Access_Computer
T2_STD_LA_RDP-Access_Computer
T2_STD_EU_RDP-Access_Computer
T2_STD_AP_AUS_RDP-Access_Computer
'@ -split [environment]::NewLine | Get-GPPReport -path D:\Temp


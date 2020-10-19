function Get-GPPReport {
  param (

    [string]
    $GPPName
  )

  $GPPName | ForEach-Object {

    $GUID = (Get-GPO -Name $_).Id

    [xml]$GpoXml = Get-GPOReport -Guid $GUID.Guid -ReportType Xml

    foreach ($setting in $GpoXml.GPO.Computer.ExtensionData.Extension.LocalUsersAndGroups.Group) {

      foreach ($user in $setting.properties.members.member.name) {

        foreach ($computer in $setting.Filters.FilterComputer.name) {

          [pscustomobject]@{
            GPO       = $GpoXml.GPO.Name
            GroupName = $setting.properties.groupName
            Members   = $user
            Computer  = $computer
          }
        }
      }
    }
  }
  Return $reportFile
}

@"
T2_STD_NA_USA_GBL_RDP-Access_Computer
T2_STD_LA_RDP-Access_Computer
T2_STD_EU_RDP-Access_Computer
T2_STD_AP_AUS_RDP-Access_Computer
"@ -split [environment]::NewLine | ForEach-Object {

  Get-GPPReport -GPPName $_ | Export-Csv "d:\temp\GPPReport.csv" -NoTypeInformation -Append

}

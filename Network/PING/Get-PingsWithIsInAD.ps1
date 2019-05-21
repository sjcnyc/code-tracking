function Ping-Host  {
  param
  (
    [string]
    $hostName
  )

  [bool] $result = 0
  $oPing = New-Object -TypeName System.Net.NetworkInformation.Ping
     
  try {
    $PingStatus = $oPing.Send("$hostName")
    if ($PingStatus.Status -eq 'Success'){
    $result = 1
    $parentcontainer = Get-QADComputer $hostName | Select-Object -ExpandProperty parentcontainer
    }
    else {$result = 0}
  }
  catch {$result = 0}
  # write-host "$($result) : $($hostName)"
    
  $pingObj = [pscustomobject] @{
    Status   = $result
    HostName = $hostName
    ParentContainer = $parentcontainer
  }
    
  $pingObj | Export-Csv c:\temp\computers_kim.csv -NoTypeInformation -Append
}

@"
USL0021CC5FB6FF
USL0021CC600B11
USL0021CC641182
"@-split [environment]::NewLine | ForEach-Object {

  Ping-Host -hostName $_

}
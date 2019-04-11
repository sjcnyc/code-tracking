#requires -Version 2 -Modules ActiveDirectory
Clear-Host

$tableOSName = 'OperatingSystems'
$tableOS = New-Object -TypeName system.Data.DataTable -ArgumentList "$tableOSName"
$colOS = New-Object -TypeName system.Data.DataColumn -ArgumentList OperatingSystem, ([string])
$colOSversion = New-Object -TypeName system.Data.DataColumn -ArgumentList OperatingSystemVersion, ([string])
$colOSType = New-Object -TypeName system.Data.DataColumn -ArgumentList OperatingSystemType, ([string])
$tableOS.columns.add($colOS)
$tableOS.columns.add($colOSversion)
$tableOS.columns.add($colOSType)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows 10'
$rowtableOS.OperatingSystemVersion = '10.0*'
$rowtableOS.OperatingSystemType = 'WorkStation'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows 8.1'
$rowtableOS.OperatingSystemVersion = '6.3'
$rowtableOS.OperatingSystemType = 'WorkStation'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows 8'
$rowtableOS.OperatingSystemVersion = '6.2'
$rowtableOS.OperatingSystemType = 'WorkStation'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows 7'
$rowtableOS.OperatingSystemVersion = '6.1'
$rowtableOS.OperatingSystemType = 'WorkStation'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows Vista'
$rowtableOS.OperatingSystemType = 'WorkStation'
$rowtableOS.OperatingSystemVersion = '6.0'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows XP 64-Bit Edition'
$rowtableOS.OperatingSystemVersion = '5.2'
$rowtableOS.OperatingSystemType = 'WorkStation'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows XP'
$rowtableOS.OperatingSystemVersion = '5.1'
$rowtableOS.OperatingSystemType = 'WorkStation'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows 2000 Professional'
$rowtableOS.OperatingSystemVersion = '5.0'
$rowtableOS.OperatingSystemType = 'WorkStation'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows Server 2016'
$rowtableOS.OperatingSystemVersion = '10.0*'
$rowtableOS.OperatingSystemType = 'Server'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows Server 2012 R2'
$rowtableOS.OperatingSystemVersion = '6.3'
$rowtableOS.OperatingSystemType = 'Server'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows Server 2012'
$rowtableOS.OperatingSystemVersion = '6.2'
$rowtableOS.OperatingSystemType = 'Server'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows Server 2008 R2'
$rowtableOS.OperatingSystemVersion = '6.1'
$rowtableOS.OperatingSystemType = 'Server'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows Server® 2008'
$rowtableOS.OperatingSystemVersion = '6.0'
$rowtableOS.OperatingSystemType = 'Server'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows Server 2003'
$rowtableOS.OperatingSystemVersion = '5.2'
$rowtableOS.OperatingSystemType = 'Server'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows 2000 Server'
$rowtableOS.OperatingSystemVersion = '5.0'
$rowtableOS.OperatingSystemType = 'Server'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows 2000 Advanced Server'
$rowtableOS.OperatingSystemVersion = '5.0'
$rowtableOS.OperatingSystemType = 'Server'
$tableOS.Rows.Add($rowtableOS)
$rowtableOS = $tableOS.NewRow()
$rowtableOS.OperatingSystem = 'Windows 2000 Datacenter Server'
$rowtableOS.OperatingSystemVersion = '5.0'
$rowtableOS.OperatingSystemType = 'Server'
$tableOS.Rows.Add($rowtableOS)

Write-Host -Object 'WorkStation Operating Systems : ' -ForegroundColor 'Green'

$WorkStationCount = 0

foreach ($object in ($tableOS | Where-Object -FilterScript {$_.OperatingSystemType -eq 'WorkStation'}))

{
  $LDAPFilter = '(&(operatingsystem=' + $object.OperatingSystem + '*)(operatingsystemversion=' + $object.OperatingSystemVersion + '*))'

  $OSCount = (Get-ADComputer -LDAPFilter $LDAPFilter).Count

  if ($OSCount -ne $null)

  {'' + $object.OperatingSystem  + ': ' + $OSCount + ''}

  else

  {
    '' + $object.OperatingSystem  + ': 0'

    $OSCount = 0
  }

  $WorkStationCount += $OSCount
}

$WorkStationTotalNumber = 'Total Number : ' + $WorkStationCount + ''

Write-Host -Object $WorkStationTotalNumber -ForegroundColor 'Yellow'

Write-Host -Object ''

Write-Host -Object 'Server Operating Systems : ' -ForegroundColor 'Green'

$ServerCount = 0

foreach ($object in ($tableOS | Where-Object -FilterScript {$_.OperatingSystemType -eq 'Server'}))

{
  $LDAPFilter = '(&(operatingsystem=' + $object.OperatingSystem + '*)(operatingsystemversion=' + $object.OperatingSystemVersion + '*))'

  $OSCount = (Get-ADComputer -LDAPFilter $LDAPFilter).Count

  if ($OSCount -ne $null)

  {'' + $object.OperatingSystem  + ': ' + $OSCount + ''}

  else

  {
    '' + $object.OperatingSystem  + ': 0'

    $OSCount = 0
  }

  $ServerCount += $OSCount
}

$ServerTotalNumber = 'Total Number : ' + $ServerCount + ''

Write-Host -Object $ServerTotalNumber -ForegroundColor 'Yellow'

Write-Host -Object ''

$LDAPFilter = '(&(operatingsystem=*)'

foreach ($object in $tableOS)

{$LDAPFilter += '(!(&(operatingsystem=' + $object.OperatingSystem + '*)(operatingsystemversion=' + $object.OperatingSystemVersion + '*)))'}

$LDAPFilter += ')'

$OthersCount = (Get-ADComputer -LDAPFilter $LDAPFilter).Count

$OthersTotalNumber = 'Total Number : ' + $OthersCount + ''

Write-Host -Object 'Other Operating Systems : ' -ForegroundColor 'Green'

Write-Host -Object $OthersTotalNumber -ForegroundColor 'Yellow'
$comps =@'
LONSMESUS003
SMEFR1SUS1P001
MILSMEWFP0002
ISTSBMEWFP003
HELBMGSRV0001
STOBMGAPP0006
VIESBMEWSUS
PRASBMEWFP001
HILSMEHYP0002  
LISSMEWFP001
WARSBMEWFP004
MADSMESERVER01
BUDSBMGWFP002
CPHSMEWSUS0002
ZRHSMEAPP008
OSLSMEWSUS001
JNBBMGAPP0001 
PYTHIA
MOWBMGDPM01
BERNMIWFP0002
MUCSMEAPP0101
KULSBMEWFP0002a
BOMSMEAPP02
JKTSBMEWFP002
AKLSMEWFP002
PEKSMEWSUS002
TWSMEWSUS002
HKGSMEWSUS002
SYDSMEWSUS001
SHASMEWSUS002
SELSMEWFP0001
RIOSBMEAPP002
MX-W2K8SONYSERVICIOS
MIASBMEWMAC001
BOGSMEWFP001
STGSBMEWFP002
BUESMEWFP001
SJOSBMEWVP003
TORSMEWSUS0003
USCULVWSUS002
'@-split [environment]::NewLine
$ErrorActionPreference = 'Continue' 
 
$percentWarning = 100 
$percentCritcal = 10 
 
$users = 'YourDistrolist@company.com' 

 
$reportPath = "$env:HOMEDRIVE\temp\" 
 
$reportName = "DiskSpaceRpt_$(Get-Date -Format ddMMyyyy).html" 
 
$diskReport = $reportPath + $reportName 
 
$redColor = '#FF0000' 
$orangeColor = '#FBB917' 
$whiteColor = '#FFFFFF' 
  
$i = 0 
 
$computers = $comps 
$datetime = Get-Date -Format 'MM-dd-yyyy_HHmmss' 
 
$titleDate = Get-Date -UFormat '%m-%d-%Y - %A' 
$header = " 
  <html> 
  <head> 
  <meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'> 
  <title>DiskSpace Report</title> 
  <STYLE TYPE='text/css'> 
  <!-- 
  td { 
  font-family: Tahoma; 
  font-size: 11px; 
  border-top: 1px solid #999999; 
  border-right: 1px solid #999999; 
  border-bottom: 1px solid #999999; 
  border-left: 1px solid #999999; 
  padding-top: 0px; 
  padding-right: 0px; 
  padding-bottom: 0px; 
  padding-left: 0px; 
  } 
  body { 
  margin-left: 5px; 
  margin-top: 5px; 
  margin-right: 0px; 
  margin-bottom: 10px; 
  table { 
  border: thin solid #000000; 
  } 
  --> 
  </style> 
  </head> 
  <body> 
  <table width='100%'> 
  <tr bgcolor='#CCCCCC'> 
  <td colspan='7' height='25' align='center'> 
  <font face='tahoma' color='#003399' size='4'><strong>Quick DiskSpace Report for Kim lol</strong></font> 
  </td> 
  </tr> 
  </table> 
" 
Add-Content $diskReport -Value $header 
  
$tableHeader = " 
  <table width='100%'><tbody> 
  <tr bgcolor=#CCCCCC> 
  <td width='10%' align='center'>Server</td> 
  <td width='5%' align='center'>Drive</td> 
  <td width='15%' align='center'>Drive Label</td> 
  <td width='10%' align='center'>Total Capacity(GB)</td> 
  <td width='10%' align='center'>Used Capacity(GB)</td> 
  <td width='10%' align='center'>Free Space(GB)</td> 
  <td width='5%' align='center'>Freespace %</td> 
  </tr> 
" 
Add-Content $diskReport -Value $tableHeader 
  
foreach($computer in $computers) 
{  
  $disks = Get-WmiObject -ComputerName $computer -Class Win32_LogicalDisk -Filter 'DriveType = 3'
  $computer = $computer.toupper() 
  foreach($disk in $disks) 
  {         
    $deviceID = $disk.DeviceID 
    $volName = $disk.VolumeName 
    [float]$size = $disk.Size 
    [float]$freespace = $disk.FreeSpace  
    $percentFree = [Math]::Round(($freespace / $size) * 100, 2) 
    $sizeGB = [Math]::Round($size / 1073741824, 2) 
    $freeSpaceGB = [Math]::Round($freespace / 1073741824, 2) 
    $usedSpaceGB = $sizeGB - $freeSpaceGB 
    $color = $whiteColor 
 
    if($percentFree -lt $percentWarning)       
    { 
      $color = $whiteColor  
 
      if($percentFree -lt $percentCritcal) 
      {
        $color = $redColor
      }         
   
      $dataRow = " 
        <tr> 
        <td width='10%'>$computer</td> 
        <td width='5%' align='center'>$deviceID</td> 
        <td width='15%' >$volName</td> 
        <td width='10%' align='center'>$sizeGB</td> 
        <td width='10%' align='center'>$usedSpaceGB</td> 
        <td width='10%' align='center'>$freeSpaceGB</td> 
        <td width='5%' bgcolor=`'$color`' align='center'>$percentFree</td> 
        </tr> 
      " 
      Add-Content $diskReport -Value $dataRow 
      Write-Host -ForegroundColor DarkYellow -Object "$computer $deviceID percentage free space = $percentFree" 
      $i++   
    } 
  } 
} 
 
$tableDescription = " 
  </table><br><table width='20%'> 
  <tr bgcolor='White'> 
  <td width='10%' align='center' bgcolor='#FBB917'>Warning less than 15% free space</td> 
  <td width='10%' align='center' bgcolor='#FF0000'>Critical less than 10% free space</td> 
  </tr> 
" 
Add-Content $diskReport -Value $tableDescription 
Add-Content $diskReport -Value '</body></html>' 
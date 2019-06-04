Function Get-DriveGridView {

Param(
[string[]]$computername = $env:COMPUTERNAME
)

Write-Host 'Collecting drive information...please wait' -ForegroundColor Green

$data = Get-WmiObject -class win32_logicaldisk -ComputerName $computername -filter 'drivetype=3' | 
Select-Object @{Name='Computername';Expression={$_.Systemname}},
@{Name='Drive';Expression={$_.DeviceID}},
@{Name='SizeMB';Expression={[int]($_.Size/1MB)}},
@{Name='FreeMB';Expression={[int]($_.Freespace/1MB)}},
@{Name='UsedMB';Expression={[math]::round(($_.size - $_.Freespace)/1MB,2)}},
@{Name='Free%';Expression={[math]::round(($_.Freespace/$_.Size)*100,2)}},
@{Name='FreeGraph';Expression={
 [int]$per=($_.Freespace/$_.Size)*100
 '|' * $per }
 } 

 $data | Out-GridView -Title 'Drive Report'
 }


 Get-DriveGridView -computername ny1,ly2
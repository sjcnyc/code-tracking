workflow Scan-Eventlogs {
param (
    [string[]]$computers
    )
 
    $filter = @{
        LogName = 'System'
        Id = '3','7036'
        StartTime = (Get-Date).AddDays(-2)
    }
 
    foreach -parallel ($computer in $computers){
        $data = New-Object -TypeName PSObject -Property @{
            Computer = $computer
            Count = Get-WinEvent -FilterHashtable $filter -ComputerName $computer | Measure-Object | Select-Object -ExpandProperty Count
        } 
        $data
    }
}
 
Scan-Eventlogs -computers 'usbvhpwfs01','usnycpwfs01' | Select-Object Computer, Count
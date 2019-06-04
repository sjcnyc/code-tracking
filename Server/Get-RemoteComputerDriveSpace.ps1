#requires -Modules PSHTMLTable

$percentWarning = '80'

$computers = @'
USCULPWSQL001
'@ -split [environment]::NewLine

foreach ($computer in $computers) {
    $disks    = Get-WmiObject -ComputerName $computer -Class Win32_LogicalDisk -Filter 'DriveType = 3'
    $computer = $computer.toupper()
    $result   = New-Object System.Collections.ArrayList

    foreach ($disk in $disks) {

        $deviceID         = $disk.DeviceID
        $volName          = $disk.VolumeName
        [float]$size      = $disk.Size
        [float]$freespace = $disk.FreeSpace
        $percentFree      = [Math]::Round(($freespace / $size) * 100, 2)
        $sizeGB           = [Math]::Round($size / 1073741824, 2)
        $freeSpaceGB      = [Math]::Round($freespace / 1073741824, 2)
        $usedSpaceGB      = $sizeGB - $freeSpaceGB

        $info = [pscustomobject]@{
            'DeviceID'    = $deviceID
            'VolumeName'  = $volName
            'Size'        = [float]$size
            'FreeSpace'   = [float]$freespace
            'PercentFree' = $percentFree
            'SizeGB'      = $sizeGB
            'FreeSpaceGB' = $freeSpaceGB
            'UserSpaceGB' = $usedSpaceGB
        }

        $result.Add($info) | Out-Null
    }
}

$HTML = New-HTMLHead -title "Free Space Report"

$params = @{
    Column      = 'PercentFree'
    ScriptBlock = {[double]$args[0] -lt [double]$args[1]}
    Attr        = 'Style'
}
$HTML += New-HTMLTable -inputObject $($result) |
    Add-HTMLTableColor -Argument 70 -AttrValue "background-color:##FF0000;" @params | Close-HTML

Set-Content -Path "$env:HOMEDRIVE\temp\test.htm" -Value $HTML
& "$env:ProgramFiles\Internet Explorer\iexplore.exe" c:\temp\test.htm
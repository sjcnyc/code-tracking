function Find-AndReplaceInHostsFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [string]$SearchString,

        [Parameter(Mandatory, Position = 1)]
        [ValidatePattern("((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")]
        [string]$AddIP,

        [Parameter(Position = 1)]
        [System.IO.FileInfo]$Path = "C:\Windows\System32\Drivers\Etc\hosts"
    )
    Get-Content -Path $Path | ForEach-Object {
        if ($_.Contains($SearchString)) {
            $_.Replace($SearchString, "$AddIP $SearchString")
        }
    }
}
function Write-HostsFile {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [ValidatePattern("((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")]
        [string]$IPAddress1 = '8.8.8.8',


        [Parameter(Position = 1)]
        [ValidatePattern("((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")]
        [string]$IPAddress2 = '8.8.4.4',

        [Parameter(Position = 2)]
        [string]$SearchString = 'googledns'
    )
    $Online1 = (Test-NetConnection $IPAddress1).PingSucceeded
    $Online2 = (Test-NetConnection $IPAddress2).PingSucceeded

    if ($Online1 -and !$Online2) {
        Find-AndReplaceInHostsFile -SearchString $SearchString -AddIp $IPAddress1
    }
    elseif ($Online2 -and !$Online1) {
        Find-AndReplaceInHostsFile -SearchString $SearchString -AddIp $IPAddress2
    }
}
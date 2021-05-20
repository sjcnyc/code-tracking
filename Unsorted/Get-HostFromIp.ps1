[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$sourceCSV,
    [string]$destCSV
)

$ErrorActionPreference = "silentlycontinue"

Import-Csv $sourceCSV | ForEach-Object {
    $ip = $_.IPAddress
    Try {
        $HostName = ([Net.Dns]::GetHostByAddress($ip)).HostName
        "" | Select-Object @{N = "IP"; E = {$ip}}, @{N = "HostName"; E = {$HostName}}
    }
    Catch {
        "" | Select-Object @{N = "IP"; E = {$ip}}, @{N = "HostName"; E = {"No HostNameFound"}}
    }
} | Export-Csv $destCSV -NoTypeInformation
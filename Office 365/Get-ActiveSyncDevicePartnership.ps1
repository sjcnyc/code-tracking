$Result = @()
foreach ($User in $UserList) {
    $MobileDeviceStatistics = Get-MobileDeviceStatistics -Mailbox $User
    foreach ($MobileDevice in $MobileDeviceStatistics) {
        if ($MobileDevice.LastSuccessSync -gt (Get-Date).AddMonths(-3)) {
            $Result += [PSCustomObject] @{
                User                        = $User
                HasDeviceThatSyncedRecently = $true
            }
            continue
        }
    }
}
$Result
$Result | Export-Csv -Encoding utf8 -Delimiter ';' -Path result.csv
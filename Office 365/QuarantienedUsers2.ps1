$mailboxUsers = get-mailbox -resultsize unlimited

$result = New-Object System.Collections.ArrayList

foreach ($user in $mailboxUsers) {
    $UPN = $user.UserPrincipalName
    $displayName = $user.DisplayName

    $mobileDevices = Get-MobileDevice -Mailbox $UPN -Filter {DeviceAccessState -eq 'Quarantined'}

    foreach ($mobileDevice in $mobileDevices) {
        $info = [pscustomobject]@{
            'Name' = $user.name
            'UPN' = $UPN
            'DisplayName' = $displayName
            'FriendlyName' = $mobileDevice.FriendlyName
            'ClientType' = $mobileDevice.ClientType
            'ClientVersion' = $mobileDevice.ClientVersion
            'DeviceId' = $mobileDevice.DeviceId
            'DeviceMobileOperator' = $mobileDevice.DeviceMobileOperator
            'DeviceModel' = $mobileDevice.DeviceModel
            'DeviceOS' = $mobileDevice.DeviceOS
            'DeviceTelephoneNumber' = $mobileDevice.DeviceTelephoneNumber
            'DeviceType' = $mobileDevice.DeviceType
            'FirstSyncTime' = $mobileDevice.FirstSyncTime
            'UserDisplayName' = $mobileDevice.UserDisplayName
        }
        $null = $result.Add($info)
    }
}

$result | Export-Csv 'C:\Temp\O365_QuarantienedUsers.csv' -NoTypeInformation
$QuarantinedUsers = Get-MobileDevice -Filter {DeviceAccessState -eq 'Quarantined'}

$result = New-Object System.Collections.ArrayList

foreach ($qUser in $QuarantinedUsers) {

    $pos = $qUser.Id.IndexOf("\")
    $username = $qUser.Id.Substring(0, $pos)
    $user = Get-ADUser -Server 'CULSMEADS0101.me.sonymusic.com' -Filter {Displayname -eq $username} -Properties Name, Mail, DisplayName, SamAccountName

    $info = [pscustomobject]@{
        'Name' = $user.Name
        'Mail' = $user.Mail
        'SamAccountName' = $user.SamAccountName
        'DisplayName' = $user.DisplayName
        'FriendlyName' = $qUser.FriendlyName
        'ClientType' = $qUser.ClientType
        'ClientVersion' = $qUser.ClientVersion
        'DeviceId' = $qUser.DeviceId
        'DeviceAccessState' = $qUser.DeviceAccessState
        'DeviceMobileOperator' = $qUser.DeviceMobileOperator
        'DeviceModel' = $qUser.DeviceModel
        'DeviceOS' = $qUser.DeviceOS
        'DeviceTelephoneNumber' = $qUser.DeviceTelephoneNumber
        'DeviceType' = $qUser.DeviceType
        'FirstSyncTime' = $qUser.FirstSyncTime
        'UserDisplayName' = $qUser.UserDisplayName
    }
    $null = $result.Add($info)
}

$result #| Export-Csv C:\Temp\O365_QuarantienedUsers.csv -NoTypeInformation

<#$mailboxUsers = get-mailbox -resultsize unlimited

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

$result | Export-Csv 'C:\Temp\O365_QuarantienedUsers.csv' -NoTypeInformation#>
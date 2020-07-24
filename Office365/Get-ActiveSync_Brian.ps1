$result = New-Object System.Collections.ArrayList

(Get-Mailbox -ResultSize unlimited |
    Where-Object {$true} -PipelineVariable mbxusers |
    Select-Object UserPrincipalName, Name |

Get-MobileDeviceStatistics |
    Select-Object Identity, DeviceImei, DeviceId, DeviceModel, DeviceUserAgent, DeviceAccessState, DeviceAccessStateReason, Guid).ForEach{

    $info = [pscustomobject]@{
        'DispalyName'             = $mbxusers.Name
        'UPN'                     = $mbxusers.UserPrincipalName
        'Identity'                = $_.Identity
        'DeviceImei'              = $_.DeviceImei
        'DeviceId'                = $_.DeviceId
        'DeviceModel'             = $_.DeviceModel
        'DeviceUserAgent'         = $_.DeviceUserAgent
        'DeviceAccessState'       = $_.DeviceAccessState
        'DeviceAccessStateReason' = $_.DeviceAccessStateReason
        'Guid'                    = $_.Guid
    }
    #$null = $result.Add($info)
    $info | Export-Csv C:\Temp\ActiveSyncDevices_002.csv -Append
}
using namespace System.Collections.Generic


$Date            = (get-date -f yyyy-MM-dd)
$CSVFile         = "c:\Temp\DefenderTokenReport_$($Date).csv"

Function Convert-IntTodate {
    Param ($Integer = 0)
    if ($null -eq $Integer) {
        $date = $null
    }
    else {
        $date = [datetime]::FromFileTime($Integer).ToString('g')
        if ($date.IsDaylightSavingTime) {
            $date = $date.AddHours(1)
        }
        $date
    }
}

$TokenSplat = @{
    SizeLimit                        = '0'
    PageSize                         = '2000'
    DontUseDefaultIncludedProperties = $true
    IncludedProperties               = @('Name', 'Description', 'defender-tokenUsersDNs')
    Type                             = 'defender-tokenClass'
    ErrorAction                      = '0'
}

$UserSplat = @{
    SizeLimit                        = '0'
    PageSize                         = '2000'
    DontUseDefaultIncludedProperties = $true
    IncludedProperties               = @('Name', 'SamAccountName', 'defender-violationCount', 'defender-resetCount', 'defender-lockoutTime', 'defender-lastlogon', 'parentcontainer')
    ErrorAction                      = '0'
}

$Result = [List[psobject]]::new()

Get-QADObject @TokenSplat | Where-Object { $($_.'defender-tokenUsersDNs') -ne $null } -PipelineVariable token |

ForEach-Object {

    try {
        Get-QADUser -Identity $($token.'defender-tokenUsersDNs') @UserSplat |
            ForEach-Object {
                $Info = [pscustomobject]@{
                    'Name'                      = $_.Name
                    'User-ID'                   = $_.SamAccountName
                    'Defender-ViolationCount'   = $_.'defender-violationCount'
                    'Defender-ResetCount'       = $_.'defender-resetCount'
                    'Defender-LockoutTime'      = (Convert-IntTodate $_.'defender-lockoutTime')
                    'Defender-LastLogon'        = (Convert-IntTodate $_.'defender-lastlogon')
                    'Defender-TokenName'        = $token.Name
                    'Defender-TokenDescription' = $token.Description
                    'Defender-ParentContainer'  = $_.ParentContainer
                }
                [void]$Result.Add($Info)
            }
    }
    catch [System.Object] {
        #$Error[0].Exception
        $($token.'defender-tokenUsersDNs')
    }
}

$Result | Export-Csv -Path $CSVFile -NoTypeInformation
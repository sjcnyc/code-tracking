Add-PSSnapin -Name Quest.Defender.AdminTools

Function Convert-IntTodate {
    Param ($Integer = 0)
    if ($Integer -eq $null) {
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

$result = New-Object -TypeName System.Collections.ArrayList

Get-QADObject @TokenSplat | Where-Object { $_.'defender-tokenUsersDNs' -ne $null } -PipelineVariable token |

ForEach-Object {

    try {
        Get-QADUser -Identity $token.'defender-tokenUsersDNs' @UserSplat |
            ForEach-Object {
            $info = [pscustomobject]@{
                'Name'                      = $_.Name
                'User-ID'                   = $_.samAccountName
                'Defender-ViolationCount'   = $_.'defender-violationCount'
                'Defender-ResetCount'       = $_.'defender-resetCount'
                'Defender-LockoutTime'      = (Convert-IntTodate $_.'defender-lockoutTime')
                'Defender-LastLogon'        = (Convert-IntTodate $_.'defender-lastlogon')
                'Defender-TokenName'        = $token.Name
                'Defender-TokenDescription' = $token.Description
                'Defender-ParentContainer'  = $_.parentcontainer
            }
            $null = $result.Add($info)
        }
    }
    catch [System.Object] {
        $Error[0].Exception
    }
}

$result | Export-Csv -Path 'c:\temp\defenderInfo_0014.csv' -NoTypeInformation
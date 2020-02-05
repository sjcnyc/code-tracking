[CmdletBinding(SupportsShouldProcess)]
Param()

function script:Set-bmgUPN {
    Param(
        [Parameter(Mandatory)][string]$user,
        [Parameter(Mandatory)][string]$UPN
    )
    try {

        if ($user -EQ ((Get-QADUser -Identity $user).SamAccountName)) {

            Set-ADUser $user -replace @{mailNickname = $UPN} -Server 'GTLSMEADS0012' -WhatIf
            Write-Verbose -Message "Set ME user: $($user) UPN: $($UPN) to: BMG MailKnickName Attribute"
        }
    }
    catch {
        Write-Output -InputObject "Error: $_"
    }
}

$qadProps = @{
    SizeLimit                       = '100'
    Service                         = 'CULSMEADS0101.me.sonymusic.com'
    DontUseDefaultIncludedPropertie = $true
    IncludedProperties              = @('SamAccountName', 'userPrincipalName')
}

Get-QADUser @qadProps | Where-Object userPrincipalName -NE $null | Select-Object SamAccountName, userPrincipalName |

ForEach-Object {

    Set-bmgUPN -user $_.SamAccountName -UPN $_.userPrincipalName
}
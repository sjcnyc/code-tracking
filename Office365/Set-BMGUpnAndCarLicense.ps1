[CmdletBinding(SupportsShouldProcess)]
Param()

function script:Set-bmgUPN {
    Param(
        [Parameter(Mandatory)][string]$user,
        [Parameter(Mandatory)][string]$UPN
    )
    try {

        if ($user -EQ ((Get-QADUser -Identity $user).SamAccountName) -and ($null -eq (Get-QADUser -Identity $user -IncludeAllProperties).carLicense)) {

            Set-ADUser $user -replace @{carLicense = $UPN} #-Server 'GTLSMEADS0012'
            Write-Verbose -Message "Set ME user: $($user) UPN: $($UPN) to: BMG carLicense Attribute"
           # Set-ADUser $user -Clear MailNickName -Server 'GTLSMEADS0012'
           # Write-Verbose "Clearing MailNickName Attribute for $($user)"
        }
    }
    catch {
        Write-Output -InputObject "Error: $_"
    }
}

$qadProps = @{
    SizeLimit                       = '0'
    Service                         = 'CULSMEADS0101.me.sonymusic.com'
    DontUseDefaultIncludedPropertie = $true
    IncludedProperties              = @('SamAccountName', 'userPrincipalName')
}

<#@'

'@-split [environment]::NewLine |

Get-QADUser @qadProps | Where-Object userPrincipalName -NE $null | Select-Object SamAccountName, userPrincipalName |

    ForEach-Object {

    Set-bmgUPN -user $_.SamAccountName -UPN $_.userPrincipalName
    }
#>

Get-QADGroup -Identity 'WWI-O365-MigratedUsers' -Service 'CULSMEADS0101.me.sonymusic.com' -SizeLimit 0 | 
    Get-QADGroupMember -SizeLimit 0 | Select-Object SamAccountName, userPrincipalName |
 
 ForEach-Object {

    Set-bmgUPN -user $_.SamAccountName -UPN $_.userPrincipalName
}

# testing

#Get-QADGroup -Identity 'WWI-O365-MigratedUsers' | Get-QADGroupMember -IncludeAllProperties | Select-Object SamAccountName, carLicense
#Set-bmgUPN -user 'sconnea' -UPN  'sean.connealy.peak@sonymusic.com'
#Set-ADUser 'blynch' -Replace @{carLicense = 'brian.lynch@arcadecg.com'} -Server 'GTLSMEADS0012'
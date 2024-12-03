<#
.SYNOPSIS
This script retrieves all AVD deployments and exports the associated AD users to a CSV file.

.DESCRIPTION
The script retrieves all AVD deployments that match the specified filter criteria and retrieves the associated AD users. The user information is then exported to a CSV file.

.PARAMETER None
This script does not accept any parameters.

.EXAMPLE
.\Get-AllAvdDeployments.ps1
Retrieves all AVD deployments and exports the associated AD users to a CSV file.

.NOTES
Author: Sean Connealy
Date:   05/10/2024
#>

$Date = (Get-Date -Format "yyyyMMdd_HHmmss")

$getAdgroupSplat = @{
    Filter     = 'Name -like "az_avd_*FullDesktop" -and Name -notlike "*AZ_AVD_*RemoteApps" -and Name -notlike "*InfraPersonal*"'
    Properties = '*'
}

$Groups = Get-Adgroup @getAdgroupSplat | Select-Object Name, DistinguishedName

$userobj =
foreach ($Group in $Groups) {
    Get-ADGroup $Group.DistinguishedName -PipelineVariable Grp -Properties Name | Get-ADGroupMember |
    Get-ADUser -Properties GivenName, SurName, SamaccountName, DistinguishedName, UserPrincipalName |
    Select-Object -Property GivenName, SurName, SamaccountName, DistinguishedName, UserPrincipalName, @{N = 'GroupName'; E = { $Grp.SamAccountName } }
}

$userobj | Export-Csv -Path C:\temp\ADUsers_$($Date).csv -NoTypeInformation

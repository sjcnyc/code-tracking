<#
.SYNOPSIS
Adds a user to Azure Virtual Desktop (AVD) groups.

.DESCRIPTION
The Add-UserToAvdGroup function adds a specified user to one or more AVD groups. It checks if the user is already a member of the group before adding them.

.PARAMETER sAMAccountName
The sAMAccountName of the user to be added to the AVD groups.

.PARAMETER Groups
The AVD groups to which the user should be added. This parameter accepts an array of group names.

.EXAMPLE
Add-UserToAvdGroup -sAMAccountName "john.doe" -Groups <tab for argument completer to list available groups>
Adds the user with sAMAccountName "john.doe" to the AVD groups specified.

.NOTES
Author: Sean Connealy
Date:   2021-09-01
Script: Add-UserToAvdGroup.ps1
pre-requisite: AzureAD module
#>

function Add-UserToAvdGroup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$sAMAccountName,
        [Parameter(Mandatory = $true)]
        [string]$Groups
    )
    try {
        foreach ($Group in $Groups) {
            $GroupDN = (Get-ADGroup -Identity $Group).DistinguishedName
            if (-not (Get-ADGroupMember -Identity $GroupDN | Where-Object { $_.sAMAccountName -eq $sAMAccountName })) {
                Add-ADGroupMember -Identity $GroupDN -Members $sAMAccountName
                Write-Host "Adding $($sAMAccountName) to AVD group: $($Group)" -ForegroundColor Green
            } else {
                Write-Host "User $($sAMAccountName) already in AVD group: $($Group)" -ForegroundColor Red
            }
        }
    } catch {
        $_.Exception.message
    }
}

Register-ArgumentCompleter -CommandName 'Add-UserToAvdGroup' -ParameterName 'Groups' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $Parameters = @{
        Filter = 'Name -like "az_avd_*FullDesktop" -and Name -notlike "*Tier*"'
        prop   = 'Name'
    }
    (Get-ADGroup @Parameters).Name | ForEach-Object { "'$_'" }
}
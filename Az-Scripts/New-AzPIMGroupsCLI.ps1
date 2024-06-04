<#
.SYNOPSIS
Creates Azure AD groups and assigns roles to management groups and subscriptions.

.DESCRIPTION
The New-AzPIMGroups function creates Azure AD groups and assigns roles to management groups and subscriptions. It supports creating groups and assigning roles for both
management groups and subscriptions, or either one of them. The function uses predefined roles such as Owner, Contributor, Reader, Billing Reader, Network Contributor,
Security Admin, and Security Reader.

.PARAMETER Roles
Specifies the roles to assign to the groups. The default value is "Owner", "Contributor", "Reader", "Billing Reader", "Network Contributor", "Security Admin", and "Security Reader".

.PARAMETER MGPrefix
Specifies the prefix to use for the management group groups. The default value is "AZ_PIM_MG_".

.PARAMETER MGSuffix
Specifies the suffix to use for the management group groups. There is no default value.

.PARAMETER SubPrefix
Specifies the prefix to use for the subscription groups. The default value is "AZ_PIM_SUB_".

.PARAMETER SubSuffix
Specifies the suffix to use for the subscription groups. There is no default value.

.PARAMETER Scope
Specifies the scope for creating groups and assigning roles. Valid values are "ManagementGroups", "Subscriptions", and "Both". The default value is "Both".

.PARAMETER ManagementGroupName
Specifies the name of the management group to create groups and assign roles to. If not specified, all management groups will be used.

.PARAMETER SubscriptionName
Specifies the name of the subscription to create groups and assign roles to. If not specified, all subscriptions will be used.

.EXAMPLE
New-AzPIMGroups -ManagementGroupName "EMEA" -Scope "ManagementGroups" -Roles "Workbook Contributor"
Creates Azure AD groups and assigns the "Workbook Contributor" role to the management group "EMEA".

.EXAMPLE
New-AzPIMGroups -SubscriptionName "EUS-ML_AI_FinancialSystems" -Scope "Subscriptions" -Roles "Contributor"
Creates Azure AD groups and assigns the "Contributor" role to the subscription "EUS-ML_AI_FinancialSystems".

.NOTES
File Name      : New-AzPIMGroupsCLI.ps1
Author         : Sean Connealy
Prerequisite   : Azure PowerShell module
Requirements   : PowerShell 5.1 or later
#>


[CmdletBinding()]
param (
    [string[]]$Roles = @("Owner", "Contributor", "Reader", "Billing Reader", "Network Contributor", "Security Admin", "Security Reader"),
    [string]$MGPrefix = "AZ_PIM_MG_",
    [string]$MGSuffix,
    [string]$SubPrefix = "AZ_PIM_SUB_",
    [string]$SubSuffix,
    [ValidateSet("ManagementGroups", "Subscriptions", "Both")]
    $Scope = "Both",
    [string]$ManagementGroupName,
    [string]$SubscriptionName
)

if ($Scope -eq "ManagementGroups" -or $Scope -eq "Both") {
    if ($ManagementGroupName -eq $null) {
        $ManagementGroups = Get-AzManagementGroup
    } else {
        $ManagementGroups = Get-AzManagementGroup -GroupId $ManagementGroupName
    }

    foreach ($ManagementGroup in $ManagementGroups) {
        foreach ($Role in $Roles) {
            Write-Output "Checking if group $($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)_$($Role.Replace(" ","_")) already exists"
            $CheckGroup = Get-AzADGroup -DisplayName "$($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)_$($Role.Replace(" ","_"))"
            if ($CheckGroup.Length -eq 0) {
                Write-Output "Group not found"
                Write-Output "Creating group: $($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)_$($Role.Replace(" ","_")) in Azure AD"
                New-AzADGroup -DisplayName "$($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)_$($Role.Replace(" ","_"))" -MailEnabled:$false -SecurityEnabled:$true -MailNickName "NotSet" | Out-Null
            } else {
                Write-Output "Group $($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)_$($Role.Replace(" ","_")) found, skipping creation"
            }
        }
        Write-Output "Waiting 60 seconds for Azure AD Groups to be created"
        Start-Sleep -Seconds 60

        foreach ($Role in $Roles) {
            Write-Output "Checking if Role assignment present"
            $GroupId = (Get-AzADGroup -DisplayName "$($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)_$($Role.Replace(" ","_"))").id
            $CheckRoleAssignment = Get-AzRoleAssignment -ObjectId $GroupId -RoleDefinitionName $Role -Scope "$($ManagementGroup.id)"
            if ($CheckRoleAssignment.Length -eq 0) {
                Write-Output "Adding role: $($Role) to management group: $($ManagementGroup.DisplayName)"
                New-AzRoleAssignment -ObjectId $GroupId -RoleDefinitionName $Role -Scope "$($ManagementGroup.id)" | Out-Null
            } else {
                Write-Output "Role assignment already present"
            }
        }
    }
}

if ($Scope -eq "Subscriptions" -or $Scope -eq "Both") {
    if ($SubscriptionName -eq $null) {
        $Subscriptions = Get-AzSubscription
    } else {
        $Subscriptions = Get-AzSubscription -SubscriptionName $SubscriptionName
    }

    foreach ($Subscription in $Subscriptions) {
        foreach ($Role in $Roles) {
            Write-Output "Checking if group $($SubPrefix)$($Subscription.Name)$($SubSuffix)_$($Role.Replace(" ","_")) already exists"
            $CheckGroup = Get-AzADGroup -DisplayName "$($SubPrefix)$($Subscription.Name)$($SubSuffix)_$($Role.Replace(" ","_"))"
            if ($CheckGroup.Length -eq 0) {
                Write-Output "Group not found"
                Write-Output "Creating group: $($SubPrefix)$($Subscription.Name)$($SubSuffix)_$($Role.Replace(" ","_")) in Azure AD"
                New-AzADGroup -DisplayName "$($SubPrefix)$($Subscription.Name)$($SubSuffix)_$($Role.Replace(" ","_"))" -MailEnabled:$false -SecurityEnabled:$true -MailNickName "NotSet" | Out-Null
            } else {
                Write-Output "Group $($SubPrefix)$($Subscription.Name)$($SubSuffix)_$($Role.Replace(" ","_")) found, skipping creation"
            }
        }
        Write-Output "Waiting 60 seconds for Azure AD Groups to be created"
        Start-Sleep -Seconds 60

        foreach ($Role in $Roles) {
            Write-Output "Checking if Role assignment present"
            $GroupId = (Get-AzADGroup -DisplayName "$($SubPrefix)$($Subscription.Name)$($SubSuffix)_$($Role.Replace(" ","_"))").id
            $CheckRoleAssignment = Get-AzRoleAssignment -ObjectId $GroupId -RoleDefinitionName $Role -Scope "/subscriptions/$($Subscription.id)"
            if ($CheckRoleAssignment.Length -eq 0) {
                Write-Output "Adding role: $($Role) to Subscription: $($Subscription.Name)"
                New-AzRoleAssignment -ObjectId $GroupId -RoleDefinitionName $Role -Scope "/subscriptions/$($Subscription.id)" | Out-Null
            } else {
                Write-Output "Role assignment already present"
            }
        }
    }
}
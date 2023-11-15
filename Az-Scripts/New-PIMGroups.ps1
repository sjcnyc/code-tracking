function New-AzPIMGroups {
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

    #roles
    # Billing Reader, Network Contributor, Security Admin, Security Reader.

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
}

# Roles: Owner, Contributor, Reader, Billing Reader, Network Contributor, Security Admin, Security Reader

#New-AzPIMGroups -ManagementGroupName "EMEA" -Scope "ManagementGroups"

New-AzPIMGroups -SubscriptionName "EUS-ML_AI_FinancialSystems" -Scope "Subscriptions" -Roles "Contributor"
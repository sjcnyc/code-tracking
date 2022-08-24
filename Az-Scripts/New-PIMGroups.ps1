function New-PIMGroups {
    [CmdletBinding()]
    param (
        [string[]]$Roles = @("Owner", "Contributor", "Reader"),
        [string]$MGPrefix = "AZ-PIM-MGT-",
        [string]$MGSuffix,
        [string]$SubPrefix = "AZ-PIM-SUB-",
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
            $ManagementGroups = Get-AzManagementGroup -GroupName $ManagementGroupName
        }

        foreach ($ManagementGroup in $ManagementGroups) {
            foreach ($Role in $Roles) {
                Write-Host "Checking if group $($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)-$($Role) already exists"
                $CheckGroup = Get-AzADGroup -DisplayName "$($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)-$($Role)"
                if ($CheckGroup.Length -eq 0) {
                    Write-Host "Group not found"
                    Write-Host "Creating group: $($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)-$($Role) in Azure AD"
                    New-AzADGroup -DisplayName "$($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)-$($Role)" -MailEnabled:$false -SecurityEnabled:$true -MailNickName "NotSet" | Out-Null
                } else {
                    Write-Host "Group $($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)-$($Role) found, skipping creation"
                }
            }
            Write-Host "Waiting 10 seconds for Azure AD Groups to be created"
            Start-Sleep -Seconds 10

            foreach ($Role in $Roles) {
                Write-Host "Checking if Role assignment present"
                $GroupId = (Get-AzADGroup -DisplayName "$($MGPrefix)$($ManagementGroup.DisplayName)$($MGSuffix)-$($Role)").id
                $CheckRoleAssignment = Get-AzRoleAssignment -ObjectId $GroupId -RoleDefinitionName $Role -Scope "$($ManagementGroup.id)"
                if ($CheckRoleAssignment.Length -eq 0) {
                    Write-Host "Adding role: $($Role) to management group: $($ManagementGroup.DisplayName)"
                    New-AzRoleAssignment -ObjectId $GroupId -RoleDefinitionName $Role -Scope "$($ManagementGroup.id)" | Out-Null
                } else {
                    Write-Host "Role assignment already present"
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
                Write-Host "Checking if group $($SubPrefix)$($Subscription.Name)$($SubSuffix)-$($Role) already exists"
                $CheckGroup = Get-AzADGroup -DisplayName "$($SubPrefix)$($Subscription.Name)$($SubSuffix)-$($Role)"
                if ($CheckGroup.Length -eq 0) {
                    Write-Host "Group not found"
                    Write-Host "Creating group: $($SubPrefix)$($Subscription.Name)$($SubSuffix)-$($Role) in Azure AD"
                    New-AzADGroup -DisplayName "$($SubPrefix)$($Subscription.Name)$($SubSuffix)-$($Role)" -MailEnabled:$false -SecurityEnabled:$true -MailNickName "NotSet" | Out-Null
                } else {
                    Write-Host "Group $($SubPrefix)$($Subscription.Name)$($SubSuffix)-$($Role) found, skipping creation"
                }
            }
            Write-Host "Waiting 10 seconds for Azure AD Groups to be created"
            Start-Sleep -Seconds 10

            foreach ($Role in $Roles) {
                Write-Host "Checking if Role assignment present"
                $GroupId = (Get-AzADGroup -DisplayName "$($SubPrefix)$($Subscription.Name)$($SubSuffix)-$($Role)").id
                $CheckRoleAssignment = Get-AzRoleAssignment -ObjectId $GroupId -RoleDefinitionName $Role -Scope "/subscriptions/$($Subscription.id)"
                if ($CheckRoleAssignment.Length -eq 0) {
                    Write-Host "Adding role: $($Role) to management group: $($Subscription.DisplayName)"
                    New-AzRoleAssignment -ObjectId $GroupId -RoleDefinitionName $Role -Scope "/subscriptions/$($Subscription.id)" | Out-Null
                } else {
                    Write-Host "Role assignment already present"
                }
            }
        }
    }
}
function Export-RoleAssignments {

    Param (
        [Parameter(Mandatory = $false)]
        [string]$OutputPath = '',
        [Parameter(Mandatory = $false)]
        [Switch]$SelectCurrentSubscription

    )

    #Get Current Context
    $CurrentContext = Get-AzContext

    #Get Azure Subscriptions
    if ($SelectCurrentSubscription) {
        #Only selection current subscription
        Write-Verbose "Only running for selected subscription $($CurrentContext.Subscription.Name)" -Verbose
        $Subscriptions = Get-AzSubscription -SubscriptionId $CurrentContext.Subscription.Id -TenantId $CurrentContext.Tenant.Id

    } else {
        Write-Verbose "Running for all subscriptions in tenant" -Verbose
        $Subscriptions = Get-AzSubscription -TenantId $CurrentContext.Tenant.Id
    }

    #Get Role roles in foreach loop
    $Report =
    foreach ($Subscription in $Subscriptions) {
        #Choose subscription
        Write-Verbose "Changing to Subscription $($Subscription.Name)" -Verbose

        $Context = Set-AzContext -TenantId $Subscription.TenantId -SubscriptionId $Subscription.Id -Force
        $Name = $Subscription.Name
        $TenantId = $Subscription.TenantId
        $SubId = $Subscription.SubscriptionId

        #Getting information about Role Assignments for choosen subscription
        Write-Verbose "Getting information about Role Assignments..." -Verbose
        $roles = Get-AzRoleAssignment | Select-Object RoleDefinitionName, DisplayName, SignInName, ObjectId, ObjectType, Scope,
        @{name = "TenantId"; expression = { $TenantId } }, @{name = "SubscriptionName"; expression = { $Name } }, @{name = "SubscriptionId"; expression = { $SubId } }

        foreach ($role in $roles) {
            #
            $DisplayName        = $role.DisplayName
            $SignInName         = $role.SignInName
            $ObjectType         = $role.ObjectType
            $RoleDefinitionName = $role.RoleDefinitionName
            $AssignmentScope    = $role.Scope
            $SubscriptionName   = $Context.Subscription.Name
            $SubscriptionID     = $Context.Subscription.SubscriptionId

            #Check for Custom Role
            $CheckForCustomRole = Get-AzRoleDefinition -Name $RoleDefinitionName
            $CustomRole = $CheckForCustomRole.IsCustom

            #New PSObject
            [PSCustomObject]@{
                SubscriptionName   = $subscriptionName
                SubscriptionID     = $subscriptionID
                DisplayName        = $DisplayName
                SignInName         = $SignInName
                ObjectType         = $ObjectType
                RoleDefinitionName = $RoleDefinitionName
                CustomRole         = $CustomRole
                AssignmentScope    = $AssignmentScope
            }
        }
    }

    if ($OutputPath) {
        #Export to CSV file
        Write-Verbose "Exporting CSV file to $OutputPath" -Verbose
        $Report | Export-Csv $OutputPath\RoleExport-$(Get-Date -Format "yyyy-MM-dd").csv

    } else {
        $Report
    }
}

Export-RoleAssignments -OutputPath "C:\Temp"
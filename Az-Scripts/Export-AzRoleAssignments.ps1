<#
.SYNOPSIS
Exports role assignments for Azure subscriptions.

.DESCRIPTION
The Export-AzRoleAssignments function retrieves information about role assignments for Azure subscriptions and exports the data to a CSV file.
It can export role assignments for a specific subscription or for all subscriptions in the tenant.

.PARAMETER OutputPath
Specifies the path where the CSV file will be exported. If not provided, the function will return the role assignment data as an object.

.PARAMETER SelectCurrentSubscription
Indicates whether to export role assignments for the current subscription only. If this switch is used, the function will only export role
assignments for the currently selected subscription.

.EXAMPLE
Export-RoleAssignments -OutputPath "C:\Temp"
Exports role assignments for all subscriptions in the tenant and saves the data to a CSV file at the specified path.

.EXAMPLE
Export-RoleAssignments -OutputPath "C:\Temp" -SelectCurrentSubscription
Exports role assignments for the currently selected subscription and saves the data to a CSV file at the specified path.

File Name      : Export-AzRoleAssignments.ps1
Author         : Sean Connealy
Prerequisite   : Azure PowerShell module
Requirements   : PowerShell 5.1 or later

#>
function Export-AzRoleAssignments {

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
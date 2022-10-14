function Set-AzSub {
    param (
        [parameter(Mandatory = $true)]
        [string]
        $Subscriptions
    )

    try {
        foreach ($Subscription in $Subscriptions) {
            Set-AzContext -Subscription $Subscription
        }
    } catch {
        $_.Exception.message
    }
}
Register-ArgumentCompleter -CommandName 'Set-AzSub' -ParameterName 'Subscriptions' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    Get-AzSubscription -TenantId (Get-AzContext).Tenant | Select-Object -ExpandProperty Name | ForEach-Object { "'$_'" }
}
# playing around with Register-ArgumentCompleter
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-6

$ADObjects = @{
    Computer = Write-Output Server, Workstation
    User     = Write-Output Employee, NonEmployee
    Groups   = Write-Output Security, Distribution
}
 
function Get-ADObjects {
    param(
        [string] $ADObjectType,
        [string] $ADObjectName
    )

    "ADObjectName: ${ADObjectName}`nADObjectType: ${ADObjectType}"
}

$GetADObjectCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $ADObjects.Keys.ForEach( {
            $CurrKey = $_
            switch ($parameterName) {
                ADObjectName {
                    $Source = $CurrKey
                    $ReturnValue = $ADObjects[$CurrKey]
                    $Filter = $fakeBoundParameter.ADObjectType
                }
                ADObjectType {
                    $Source = $ADObjects[$CurrKey]
                    $ReturnValue = $CurrKey
                    $Filter = $fakeBoundParameter.ADObjectName
                }
 
                default { return }
            }
            if ($Source -like "${Filter}*") {
                $ReturnValue
            }
        }) | Sort-Object -Unique | Where-Object { $_ -like "${wordToComplete}*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
Write-Output ADObjectType, ADObjectName | ForEach-Object {
    Register-ArgumentCompleter -CommandName Get-ADObjects -ParameterName $_ -ScriptBlock $GetADObjectCompleter
}
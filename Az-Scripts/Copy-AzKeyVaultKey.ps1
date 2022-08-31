function Copy-AzKeyVaultKey {
    [CmdletBinding()]
    param (
        [string]
        $sourceVault,

        [string]
        $destinationVault
    )

    (az keyvault secret list --vault-name $sourceVault --query "[].{id:id,name:name}") | ConvertFrom-Json

    ForEach-Object {
        $secretName   = $_.name
        $secretExists = (az keyvault secret list --vault-name $destinationVault --query "[?name=='$name']" -o tsv)
        if ($null -eq $secretExists) {
            Write-Output "Copy Secret across $secretName"
            $secretValue = (az keyvault secret show --vault-name $sourceVault -n $secretName --query "value" -o tsv)
            az keyvault secret set --vault-name $destinationVault -n $secretName --value "$secretValue"
        }
        else {
            Write-Output "$secretName already exists in $destinationVault"
        }
    }
}
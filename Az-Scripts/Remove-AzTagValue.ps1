function Remove-AzureTagValue {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $SubscriptionName,

        [Parameter(ParameterSetName = "TagName", Mandatory)]
        [Parameter(ParameterSetName = "TagValue", Mandatory)]
        [string]
        $TagName,

        [Parameter(ParameterSetName = "TagValue", Mandatory)]
        [string]
        $TagValue,

        [Parameter(ParameterSetName = "TagObject", Mandatory)]
        [object]
        $Tag
    )

    Set-AzContext -SubscriptionName $SubscriptionName -ErrorAction:Stop

    switch ($PSCmdlet.ParameterSetName) {
        "TagName" {
            Get-AzResourceGroup | Where-Object { $null -ne $_.Tags -and $_.Tags.ContainsKey("$TagName") } |  ForEach-Object {
                $_.Tags.Remove("$TagName")
                Update-AzTag -ResourceId $_.ResourceId -Tag $_.Tags -Operation Replace
            }

            Get-AzResource -TagName "$TagName" | ForEach-Object {
                $_.Tags.Remove("$TagName")
                Update-AzTag -ResourceId $_.Id -Tag $_.Tags -Operation Replace
            }
        }
        "TagValue" {
            Get-AzResourceGroup -Tag @{"$TagName" = "$TagValue" } | ForEach-Object {
                Update-AzTag -ResourceId $_.ResourceId -Tag @{"$TagName" = "$TagValue" } -Operation Delete
            }

            Get-AzResource -Tag @{"$TagName" = "$TagValue" } | ForEach-Object {
                Update-AzTag -ResourceId $_.Id -Tag @{"$TagName" = "$TagValue" } -Operation Delete
            }
        }
        "TagObject" {
            Get-AzResourceGroup -Tag $Tag | ForEach-Object {
                Update-AzTag -ResourceId $_.ResourceId -Tag $Tag -Operation Delete
            }

            Get-AzResource -Tag $Tag | ForEach-Object {
                Update-AzTag -ResourceId $_.Id -Tag $Tag -Operation Delete
            }
        }
    }
}
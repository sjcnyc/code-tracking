<#
.SYNOPSIS
    Removes Azure resource tags based on tag name, tag value, or tag object.

.DESCRIPTION
    The Remove-AzureTagValue function removes Azure resource tags based on the specified tag name, tag value, or tag object.
    It supports removing tags from both resource groups and individual resources.

.PARAMETER SubscriptionName
    Specifies the name of the Azure subscription to use.

.PARAMETER TagName
    Specifies the name of the tag to remove. This parameter is used when removing tags based on tag name or tag value.

.PARAMETER TagValue
    Specifies the value of the tag to remove. This parameter is used when removing tags based on tag value.

.PARAMETER Tag
    Specifies the tag object to remove. This parameter is used when removing tags based on a tag object.

.EXAMPLE
    Remove-AzureTagValue -SubscriptionName "MySubscription" -TagName "Environment"

    This example removes all tags with the name "Environment" from all resource groups and resources in the specified Azure subscription.

.EXAMPLE
    Remove-AzureTagValue -SubscriptionName "MySubscription" -TagName "Environment" -TagValue "Production"

    This example removes all tags with the name "Environment" and the value "Production" from all resource groups and resources in the specified Azure subscription.

.EXAMPLE
    $tag = @{
        Name = "Environment"
        Value = "Staging"
    }
    Remove-AzureTagValue -SubscriptionName "MySubscription" -Tag $tag

    This example removes the specified tag object from all resource groups and resources in the specified Azure subscription.

.NOTES
File Name      : Remove-AzTagValue.ps1
Author         : Sean Connealy
Prerequisite   : Azure PowerShell module
Requirements   : PowerShell 5.1 or later
#>

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
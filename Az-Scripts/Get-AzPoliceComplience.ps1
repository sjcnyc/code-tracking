# Get state on root
## Get
$PolicyStateRoot = Get-AzPolicyState -ManagementGroupName 'AMERICAS'

## Output as gridview
$PolicyStateRoot | Group-Object -Property 'PolicyDefinitionReferenceId' | ForEach-Object -Process {
    [PSCustomObject]@{
        'Definition'   = [string] $_.'Name'
        'Compliant'    = [uint16] $_.'Group'.Where{$_.'ComplianceState' -eq 'Compliant'}.'Count'
        'NonCompliant' = [uint16] $_.'Group'.Where{$_.'ComplianceState' -eq 'NonCompliant'}.'Count'
        'Total'        = [uint16] $_.'Group'.'Count'
    }
} | Out-GridView
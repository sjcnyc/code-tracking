function Get-DCsInForest {
    [CmdletBinding()]
    param(
        [string]$ReferenceDomain = $env:USERDOMAIN
    )
 
    $ForestObj = Get-ADForest -Server $ReferenceDomain
    foreach ($Domain in $ForestObj.Domains) {
        Get-ADDomainController -Filter * -Server $Domain | Select-Object Domain, HostName, Site
    }
}
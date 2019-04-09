<#
    .SYNOPSIS
    Create Microsoft DNS zone delegation for Isilon SmartConnect

    .DESCRIPTION
    Create Microsoft DNS zone delegation for Isilon SmartConnect

    .PARAMETER ParentZoneName
    Specifies the name of the parent zone. The child zone is part of this zone.

    .PARAMETER ChildZoneName
    Specifies a name of the child zone.

    .PARAMETER NameServer
    Specifies the name of the DNS server that hosts the child zone.

    .PARAMETER IPAddress
    Specifies an array of IP addresses for DNS servers for the child zone.

    .EXAMPLE
    New-IsilonZoneDSelegation -ParentZoneName 'bmg.bagint.com' -ChildZoneName aomaisir -NameServer 'sc-sip.bmg.bagint.com' -IPAddress '10.12.113.20'

    .NOTES
    Saves a lot of clicky clicky
#>
function New-IsilonZoneDSelegation {
    [CmdletBinding()]
    param(
        [string]$ParentZoneName,
        [string]$ChildZoneName,
        [string]$NameServer,
        [Object]$IPAddress
    )

    try {
        Add-DnsServerZoneDelegation -Name $ParentZoneName -ChildZoneName $ChildZoneName -NameServer $NameServer -IPAddress $IPAddress
    }
    catch {
            $error
    }
}
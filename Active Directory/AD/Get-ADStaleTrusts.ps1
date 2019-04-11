function Get-ADStaleTrusts {
    <#
    .SYNOPSIS
    Performs an inventory of the trusts in your Active Directory environment.
    .DESCRIPTION
    PErforms an inventory of the trusts in your Active Directory environment
    by using the repadmin tool. Both outgoing and incoming trusts are shown
    with their last succesful synchronization date.
    .EXAMPLE
    This example shows how to start the function.
    PS E:\> Get-ADStateTrusts
    .NOTES
    Author:   Jeff Wouters
    Requires: Active Directory PowerShell module
    #>
    $Items = Get-ADObject -Filter {ObjectClass -eq 'trustedDomain'} | Sort-Object
    $PDC = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() | Select-Object -ExpandProperty 'PDCRoleOwner'
    foreach ($Item in $Items) {
        $QueryResult = repadmin /showobjmeta $PDC ($Item.DistinguishedName)
        foreach ($Query in $QueryResult) {
            foreach ($Line in $Query) {
                if (($Line -match '(\d+)-(\d+)-(\d+) (\d+):(\d+):(?:\d+)') -and (($Line -like '*trustAuthIncoming*') -or ($Line -like '*trustAuthOutgoing*'))) {
                    $Object = New-Object -TypeName PSObject
                    $TargetFullName = [regex]::match($Line,'([a-zA-Z0-9]+)\\[a-zA-Z0-9]{3}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{6}').value
                    $Target = [regex]::match($Line,'[a-fA-F0-9]{8}-([a-fA-F0-9]{4}-){3}[a-fA-F0-9]{12}').value
                    $Date = [regex]::match($Line,'(\d{4})-(\d{2})-(\d{2})').value
                    $Time = [regex]::match($Line,'(\d{2}):(\d{2}):(?:\d{2})').value
                    $InOut = [regex]::match($Line,'(trustAuthIncoming|trustAuthOutgoing)').value
                    $Object | Add-Member -MemberType NoteProperty -name 'Trust' -Value $Item.Name
                    if ($TargetFullName -ne '') {
                        $Object | Add-Member -MemberType NoteProperty -Name 'Target' -Value $TargetFullName
                    } else {
                        $Object | Add-Member -MemberType NoteProperty -Name 'Target' -Value $Target
                    }
                    $Object | Add-Member -MemberType NoteProperty -Name 'LastSyncDate' -Value $Date
                    $Object | Add-Member -MemberType NoteProperty -Name 'LastSyncTime' -Value $Time
                    $Object | Add-Member -MemberType NoteProperty -Name 'InOut' -Value $InOut
                    $Object
                    $query
                }
            }
        }
    }
}
function Get-ADNestedGroupMembers {
    <#
.SYNOPSIS
Author: Piotr Lewandowski
Version: 1.01 (04.11.2014)
Get nested group membership from a given group or a number of groups.

.DESCRIPTION
Function enumerates members of a given AD group recursively along with nesting level and parent group information.
It also displays if each user account is enabled.
When used with an -indent switch, it will display only names, but in a more user-friendly way (sort of a tree view)

.EXAMPLE
Get-ADNestedGroupMembers "MyGroup1", "MyGroup2" | Export-CSV .\NedstedMembers.csv -NoTypeInformation

.EXAMPLE
Get-ADGroup "MyGroup" | Get-ADNestedGroupMembers | ft -autosize

.EXAMPLE
Get-ADNestedGroupMembers "MyGroup" -indent

.EXAMPLE
"MyGroup1", "MyGroup2" | Get-ADNestedGroupMembers  -indent
#>
    #Requires –Modules ActiveDirectory
    param (
        [Parameter(ValuefromPipeline = $true, mandatory = $true)][String] $GroupName,
        [int] $nesting = -1,
        [int]$circular = $null,
        [switch]$indent
    )
    BEGIN {
        function indent {
            Param($list)
            foreach ($line in $list) {
                $space = $null

                for ($i = 0; $i -lt $line.nesting; $i++) {
                    $space += '    '
                }
                $line.name = "$space" + "$($line.name)"
            }
            return $List
        }
        $modules = get-module | Select-Object -expand name
        $nesting++
    }
    PROCESS {
        if ($modules -contains 'ActiveDirectory') {
            if ($indent -and $nesting -eq 0) {
                [console]::foregroundcolor = 'green'
                write-output $GroupName
                [console]::ResetColor()
            }

            $table = $null
            $nestedmembers = $null
            $adgroupname = $null
            $ADGroupname = get-adgroup $groupname -properties memberof, members
            $memberof = $adgroupname | Select-Object -expand memberof
            write-verbose "Checking group: $($adgroupname.name)"
            if ($adgroupname) {
                if ($circular) {
                    $nestedMembers = Get-ADGroupMember -Identity $GroupName -recursive
                    $circular = $null
                }
                else {
                    $nestedMembers = Get-ADGroupMember -Identity $GroupName | Sort-Object objectclass -Descending
                    if (!($nestedmembers)) {
                        $unknown = $ADGroupname | Select-Object -expand members
                        if ($unknown) {
                            $nestedmembers = @()
                            foreach ($member in $unknown) {
                                $nestedmembers += get-adobject $member
                            }
                        }
                    }
                }

                foreach ($nestedmember in $nestedmembers) {
                    $Props = @{Type = $nestedmember.objectclass; Name = $nestedmember.name; ParentGroup = $ADgroupname.name; Enabled = ''; Nesting = $nesting; DN = $nestedmember.distinguishedname; Comment = ''}

                    if ($nestedmember.objectclass -eq 'user') {
                        $nestedADMember = get-aduser $nestedmember -properties enabled
                        $table = new-object psobject -property $props
                        $table.enabled = $nestedadmember.enabled
                        if ($indent) {
                            indent $table | Select-Object -expand name
                        }
                        else {
                            $table | Select-Object type, name, parentgroup, enabled, nesting, dn, comment
                        }
                    }
                    elseif ($nestedmember.objectclass -eq 'group') {
                        $table = new-object psobject -Property $props

                        if ($memberof -contains $nestedmember.distinguishedname) {
                            $table.comment = 'Circular membership'
                            $circular = 1
                        }
                        if ($indent) {
                            indent $table | Select-Object name, comment | ForEach-Object {

                                if ($_.comment -ne '') {
                                    [console]::foregroundcolor = 'red'
                                    write-output "$($_.name) (Circular Membership)"
                                    [console]::ResetColor()
                                }
                                else {
                                    [console]::foregroundcolor = 'yellow'
                                    write-output "$($_.name)"
                                    [console]::ResetColor()
                                }
                            }
                        }
                        else {
                            $table | Select-Object type, name, parentgroup, enabled, nesting, dn, comment
                        }
                        if ($indent) {
                            Get-ADNestedGroupMembers -GroupName $nestedmember.distinguishedName -nesting $nesting -circular $circular -indent
                        }
                        else {
                            Get-ADNestedGroupMembers -GroupName $nestedmember.distinguishedName -nesting $nesting -circular $circular
                        }
                    }
                    else {

                        if ($nestedmember) {
                            $table = new-object psobject -property $props
                            if ($indent) {
                                indent $table | Select-Object name
                            }
                            else {
                                $table | Select-Object type, name, parentgroup, enabled, nesting, dn, comment
                            }
                        }
                    }

                }
            }
        }
        else {Write-Warning 'Active Directory module is not loaded'}
    }
    END {
    }
}

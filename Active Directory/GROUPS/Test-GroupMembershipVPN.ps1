#Requires -Version 3.0
<#
    .SYNOPSIS 

    .DESCRIPTION


    .NOTES 
    File Name  : Test-GroupMembership
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0
    .LINK 
    This script posted to:
        http://www.github/sjcnyc
    .EXAMPLE

    .EXAMPLE

#>
Function Test-GroupMembership {
    Param(
        [string]$user,
        [string]$group,
        [bool]$export = $false
    )
    Get-QADUser $user | Select-Object memberof -Unique | ForEach-Object {
        $result = $false
        foreach ($i in $_.memberof) {
            if ((Get-QADGroup $i).name -like $group) {
                $result = $true
                break
            }
        }

        $user2 = Get-QADUser $user | Select-Object firstname, lastname, parentcontainer

        $PSObj = [pscustomobject]@{
            Firstname       = $user2.firstname
            Lastname        = $user2.Lastname
            ParentContainer = $user2.ParentContainer
            Name            = $user
            Group           = $group
            IsMemberVpn     = $result
        }

        if ($export) {
            $PSObj | export-csv c:\temp\report_temp.csv -notype -Append
        }
        else {
            $PSObj
        }
    }
}

$users = @"
sc_testuser
"@ -split [environment]::NewLine

foreach ($user in $users) {

    Test-GroupMembership -user $user -group 'WWI-Juniper-SSL*' -export:$false

}
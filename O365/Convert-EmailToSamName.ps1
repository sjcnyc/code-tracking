using namespace System.Collections.Generic
function Get-SamFromEmail {

    [CmdletBinding()]
    Param(
        [string]$InputCSV,
        [string]$OutputCSV,
        [string]$username
    )

    Import-Module -Name ActiveDirectory

    $result = [List[PSObject]]::new()

    $props = @{
        Properties = "sAMAccountName", "mail"
        Filter     = { Mail -eq $username }
    }

    $user = Get-ADUser @props | Select-Object $props.Properties

    $info = [pscustomobject]@{
        'originalName'    = $username
        'mail'            = $user.Mail
        'sAMAccountName ' = $user.SamAccountName
    }
    [void]$result.Add($info)

    return $result
}

$users = @"
amy.ceitinn@sonymusic.com
bella.alias@sonymusic.com
billiebonita.schmidt@sonymusic.com
Carla.vasquez@sonymusic.com
hannah.marsh@sonymusic.com
helena.hewitt@sonymusic.com
james.marcus@sonymusic.com
jasmine.aguilar@sonymusic.com
laura.cruciani@sonymusic.com
manny.vallarino@sonymusic.com
matheus.baez@sonymusic.com
melissa.robson@sonymusic.com
pedro.costa@sonymusic.com
rahul.joseph@sonymusic.com
ruwan.kodikara@sonymusic.com
steven.wang@sonymusic.com
timaj.sukker@sonymusic.com
"@ -split [environment]::NewLine

$users = foreach ($user in $users) {
    Get-SamFromEmail -username $user
}

$users
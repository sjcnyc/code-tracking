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
amy.song@sonymusic.com
esther.park@sonymusic.com
laura.hand@sonymusic.com
laura.wynne@sonymusic.com
natalie.davis@sonymusic.com
stephen.jang@sonymusic.com
"@ -split [environment]::NewLine

$users = foreach ($user in $users) {
    Get-SamFromEmail -username $user
}

$users
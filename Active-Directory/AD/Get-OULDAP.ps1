
function Get-OULDAP {
    Param (
        [string]$Search
    )
    Import-Module -Name ActiveDirectory -ErrorAction SilentlyContinue

    $OUs = Get-ADOrganizationalUnit -Filter * |
        Where-Object -FilterScript {
        $_.distinguishedname -like "*$Search*"
    } |
        Sort-Object -Property Name

    $MenuItem = 0
    Clear-Host
    Write-Host -Object "Select the OU you want and the LDAP value will be copied to the clipboard.`n"
    foreach ($OU in $OUs) {
        $MenuItem ++
        $MenuText = ($OU |
                Select-Object -Property Name, DistinguishedName |
                Format-Table -HideTableHeaders |
                Out-String).Trim()
        if ($MenuItem -lt 21) {
            [string]$Select = " $MenuItem"
        }
        else {
            [string]$Select = $MenuItem
        }
        Write-Host -Object "$Select. $MenuText"
    }

    $Prompt = Read-Host -Prompt "`n`nEnter number of the OU you want, or ctrl-c to quit"
    if (-not $Prompt) {
        Break
    }
    Try {
        $Prompt = [int]$Prompt
    }
    Catch {
        Write-Host -Object "`nSorry, invalid entry. Try again!"
        Break
    }
    if ($Prompt -lt 1 -or $Prompt -gt $MenuItem) {
        Write-Host -Object "`nSorry, invalid entry. Try again!"
    }
    else {
        Write-Host -Object "`n`n$($OUs[$Prompt - 1].distinguishedName) copied to clipboard"
        $($OUs[$Prompt - 1].distinguishedName) | clip.exe
    }
}
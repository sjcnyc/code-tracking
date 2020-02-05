[CmdletBinding(SupportsShouldProcess)]
Param()

    Clear-Host

    $mainMenu = New-SimpleMenu -Title "Connect to O365" -TitleForegroundColor Cyan -Items @(
        "AzureActiveDirectory"   | New-SimpleMenuItem -Action {Connect-AzureActiveDirectory}
        "ExchangeOnline"         | New-SimpleMenuItem -Action {Connect-ExchangeOnline}
        "AzureRMS"               | New-SimpleMenuItem -Action {Connect-AzureRMS}
        "SharePointOnline"       | New-SimpleMenuItem -Action {Connect-SharePointOnline}
        "SkypeOnline"            | New-SimpleMenuItem -Action {Connect-SkypeOnline}
        "MSTeams"                | New-SimpleMenuItem -Action {Connect-MSTeams}
        "ComplianceCenter"       | New-SimpleMenuItem -Action {CConnect-ComplianceCenter}
        "EOP"                    | New-SimpleMenuItem -Action {Connect-EOP}
        "Exit"                   | New-SimpleMenuItem -Key "x" -Action { Clear-Host} -Quit -NoPause
    )
    Invoke-SimpleMenu -Menu $mainMenu

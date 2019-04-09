function call-Menu {

Clear-Host

    $mainMenu = New-SimpleMenu -Title "SonyPosh Repository" -TitleForegroundColor Cyan -Items @(
        "List Modules"   | New-SimpleMenuItem -Action {Find-Module -Repository 'SonyPosh' | Out-GridView -PassThru | Install-Module -Verbose -Scope CurrentUser}
        "List Scripts"   | New-SimpleMenuItem -Action {Find-Script -Repository 'SonyPosh' | Out-GridView -PassThru | Install-Script -Verbose -Scope CurrentUser}
        "Add Module"     | New-SimpleMenuItem -Action { Write-Host "Add Module" }
        "Add Scripts"    | New-SimpleMenuItem -Action { Write-Host "AddScripts" }
        "Update Modules" | New-SimpleMenuItem -Action {Find-Module -Repository 'SonyPosh' | Update-Module -Force}
        "Exit"           | New-SimpleMenuItem -Key "x" -Action { Clear-Host} -Quit -NoPause
    )


if (Get-PSRepository -Name 'SonyPosh') {
    Write-Output "Repository SonyPosh Exists."
}
else {
    $repository = @{
        Name               = 'SonyPosh'
        SourceLocation     = '\\storage\data$\infra_dev\Repository'
        PublishLocation    = '\\storage\data$\infra_dev\Repository'
        InstallationPolicy = 'Trusted'
    }
    Register-PSRepository @repository
}

Invoke-SimpleMenu -Menu $mainMenu

}

call-Menu
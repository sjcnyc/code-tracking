$installModuleSplat = @{
    Name = 'Update-AllPSModules', 'MicrosoftTeams', 'Microsoft.Online.SharePoint.PowerShell', 'Microsoft.Graph', 'ExchangeOnlineManagement', 'Az', 'PSReadline'
}

Install-Module @installModuleSplat -Scope AllUsers -Force -AllowClobber -Verbose -SkipPublisherCheck
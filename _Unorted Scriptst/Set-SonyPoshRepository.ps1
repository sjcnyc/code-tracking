$repositoryName = 'SonyPosh'
$path = '\\storage\data$\infra_dev\Repository'

Register-PSRepository -Name $repositoryName -SourceLocation $path -ScriptSourceLocation $path -InstallationPolicy Trusted

Get-PSRepository -Name SonyPosh
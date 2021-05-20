Connect-AZAccount

$Subscription = Get-AzSubscription | Out-GridView -PassThru

Install-Module Microsoft.RDInfra.RDPowerShell
Import-Module Microsoft.RDInfra.RDPowerShell

Add-RDSAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com

$WVDTenantName = 'WVD Pool 1'

New-RdsTenant -name $WVDTenantName -AadTenantId $Subscription.TenantId -AzureSubscriptionId $Subscription.Id

Import-Module AzureAD

$AzureADAppDisplayName = 'Windows Virtual Desktop Svc Principal'
$aadContext = Connect-AzureAD
$svcPrincipal = New-AzureADApplication -AvailableToOtherTenants $true -DisplayName $AzureADAppDisplayName
$svcPrincipalCreds = New-AzureADApplicationPasswordCredential -ObjectId $svcPrincipal.ObjectId
$AzureADApplication = @{
    Name = $AzureADAppDisplayName
    AppID = $svcPrincipal.AppId
    Password =$svcPrincipalCreds.Value
    TenantGuid =$aadContext.TenantId.Guid
}

$AzureADApplication
#region clear variables & in memory parameters
$slb = $null
$vm = $null
$NI = $null
$natrules = $null
$NIConfig = $null
$ELBPurpose = $null
$ELBlocation = $null
$SKU = $null
#endregion

#region input variables
$ELBPurpose = 'AVD SNAT'
$ELBlocation = 'eastUS'
$SKU = 'standard'
$ELBResourceGroup = 'RG-AVDELB-P-EUS'
#endregion

#region naming convention
$ELBconvention = '-elb'
$PIPconvention = '-pip'
$FrontEndConvention = '-fep'
$BackEndConvention = '-bep'
$OutboundRuleConvention = '-obr'

$ELBname = $ELBPurpose + $ELBconvention
$ELBpip = $ELBname + $PIPconvention
$ELBFrontEndName = $ELBname + $FrontEndConvention
$ELDBackEndPoolName = $ELBname + $BackEndConvention
$ELBOutboundRulename = $ELBname + $OutboundRuleConvention
#endregion

#region loadbalancer deployment

# Create a new static public IP address
$newAzPublicIpAddressSplat = @{
    ResourceGroupName = $ELBResourceGroup
    name              = $ELBpip
    Location          = $ELBlocation
    AllocationMethod  = 'Static'
    Sku               = $SKU
}

$publicip = New-AzPublicIpAddress @newAzPublicIpAddressSplat

# Create a new front end pool configuration and assign the public IP
$frontend = New-AzLoadBalancerFrontendIpConfig -Name $ELBFrontEndName -PublicIpAddress $publicip

# Create a new back end pool configuration
$backendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $ELDBackEndPoolName


# Create the actual load balancer
$newAzLoadBalancerSplat = @{
    Name                    = $ELBname
    ResourceGroupName       = $ELBResourceGroup
    Location                = $ELBlocation
    FrontendIpConfiguration = $frontend
    BackendAddressPool      = $backendAddressPool
    Sku                     = $SKU
}

$slb = New-AzLoadBalancer @newAzLoadBalancerSplat

# Assign the back end VMs to the loadbalancer
$VMs = Get-AzVM | Out-GridView -PassThru -Title 'Select your AVD hosts'

foreach ($vm in $VMs) {
    $NI = Get-AzNetworkInterface | Where-Object { $_.name -like "*$($VM.name)*" }
    $NI.IpConfigurations[0].Subnet.Id
    $bep = Get-AzLoadBalancerBackendAddressPoolConfig -Name $ELDBackEndPoolName -LoadBalancer $slb
    $NI.IpConfigurations[0].LoadBalancerBackendAddressPools = $bep
    $NI | Set-AzNetworkInterface
}

# Assign the outbound SNAT rules
$myelb = Get-AzLoadBalancer -Name $slb.Name
$addAzLoadBalancerOutboundRuleConfigSplat = @{
    Name                    = $ELBOutboundRulename
    FrontendIpConfiguration = $frontend
    BackendAddressPool      = $backendAddressPool
    Protocol                = 'All'
}

$myelb | Add-AzLoadBalancerOutboundRuleConfig @addAzLoadBalancerOutboundRuleConfigSplat

# Configure the loadbalancer
$myelb | Set-AzLoadBalancer

#endregion
#region clear variables & in memory parameters
$slb = $null
$vm = $null
$NI = $null
$ELBlocation = $null
$SKU =  $null
#endregion

#region input variables
$ELBlocation = "EastUS"
$SKU = "standard"
$ELBResourceGroup =  "RG-ELB-P-EUS"
#endregion

#region naming convention
$ELBname = "ELB-AVD-P-EUS"
$ELBpip = "PIP-AVD-P-EUS"
$ELBFrontEndName = "FEP-AVD-P-EUS"
$ELDBackEndPoolName = "BEP-AVD-P-EUS"
$ELBOutboundRulename = "OBR-AVD-P-EUS"
#endregion

#region loadbalancer deployment

# Step 1: Create a new static public IP address
$publicip = New-AzPublicIpAddress -ResourceGroupName $ELBResourceGroup -name $ELBpip -Location $ELBlocation -AllocationMethod Static -Sku $SKU

# Step 2: Create a new front end pool configuration and assign the public IP
$frontend = New-AzLoadBalancerFrontendIpConfig -Name $ELBFrontEndName -PublicIpAddress $publicip

# Step 3: Create a new back end pool configuration
$backendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $ELDBackEndPoolName


# Step 4: Create the actual load balancer
$slb = New-AzLoadBalancer -Name $ELBname -ResourceGroupName $ELBResourceGroup -Location $ELBlocation -FrontendIpConfiguration $frontend -BackendAddressPool $backendAddressPool -Sku $SKU

# Step 5: Assign the back end VMs to the loadbalancer
$VMs = Get-AzVM | Out-GridView -PassThru -Title "Select your WVD hosts"

foreach ($vm in $VMs) {
    $NI = Get-AzNetworkInterface | Where-Object { $_.name -like "*$($VM.name)*" }
    $NI.IpConfigurations[0].Subnet.Id
    $bep = Get-AzLoadBalancerBackendAddressPoolConfig -Name $ELDBackEndPoolName -LoadBalancer $slb
    $NI.IpConfigurations[0].LoadBalancerBackendAddressPools = $bep
    $NI | Set-AzNetworkInterface
}

# Step 6: Assign the outbound SNAT rules
$myelb = Get-AzLoadBalancer -Name $slb.Name
$myelb | Add-AzLoadBalancerOutboundRuleConfig -Name $ELBOutboundRulename -FrontendIpConfiguration $frontend -BackendAddressPool $backendAddressPool -Protocol "All"

# Step 7: Configure the loadbalancer
$myelb | Set-AzLoadBalancer

#endregion
$rg = "RG-SFTP-P-EUS"
$location = "EastUS"
$storageaccountname = "stsftpstorage"
$staticEP = "10.0.1.10"
$SubscriptionName = "EUS-INFRA"
$UserPrincipalName = "sean.connealy.peak@sonymusic.com"
$ContainerName = "sftpdatapeus"

# Create a new resource group
New-AzResourceGroup -Name $rg -Location $location

# Create new subnets for the firewall
$FWsub = New-AzVirtualNetworkSubnetConfig -Name AzureFirewallSubnet -AddressPrefix 10.0.0.0/26
$Worksub = New-AzVirtualNetworkSubnetConfig -Name Workload-SN -AddressPrefix 10.0.1.0/24

# Create a new VNet
$newAzVirtualNetworkSplat = @{
    Name = 'vnet-fw-p-eus'
    ResourceGroupName = $rg
    Location = $location
    AddressPrefix = '10.0.0.0/23'
    Subnet = $FWsub, $Worksub
}

$testVnet = New-AzVirtualNetwork @newAzVirtualNetworkSplat

# Create a public IP address for the firewall
$newAzPublicIpAddressSplat = @{
    ResourceGroupName = $rg
    Location = $location
    AllocationMethod = 'Static'
    Sku = 'Standard'
    Name = 'fw-pip-p-eus'
}

$pip = New-AzPublicIpAddress @newAzPublicIpAddressSplat

# Create a new firewall policy
$policy = New-AzFirewallPolicy -Name "fw-pol" -ResourceGroupName "$rg" -Location $location

# Define new rules to add
$newAzFirewallPolicyNatRuleSplat = @{
    Name = "dnat-rule1"
    Protocol = "TCP", "UDP"
    SourceAddress = "*"
    DestinationAddress = $pip.ipaddress
    DestinationPort = "22"
    TranslatedAddress = $staticEP
    TranslatedPort = "22"
}

$newrule1 = New-AzFirewallPolicyNatRule @newAzFirewallPolicyNatRuleSplat

# Add the new rules to the local rule collection object
$newAzFirewallPolicyNatRuleCollectionSplat = @{
    Name = "NATRuleCollection"
    Priority = 100
    ActionType = "Dnat"
    Rule = $newrule1
}

$natrulecollection = New-AzFirewallPolicyNatRuleCollection @newAzFirewallPolicyNatRuleCollectionSplat

# Create a new rule collection group
$newAzFirewallPolicyRuleCollectionGroupSplat = @{
    Name = "rcg-01"
    ResourceGroupName = "$rg"
    FirewallPolicyName = "fw-pol"
    Priority = 100
}

$natrulecollectiongroup = New-AzFirewallPolicyRuleCollectionGroup @newAzFirewallPolicyRuleCollectionGroupSplat

# Add the new NAT rule collection to the rule collection group
$natrulecollectiongroup.Properties.RuleCollection = $natrulecollection

# Update the rule collection
$setAzFirewallPolicyRuleCollectionGroupSplat = @{
    Name = "rcg-01 "
    FirewallPolicyObject = $policy
    Priority = 200
    RuleCollection = $natrulecollectiongroup.Properties.rulecollection
}

Set-AzFirewallPolicyRuleCollectionGroup @setAzFirewallPolicyRuleCollectionGroupSplat

# Create the firewall
#$firewall =
$newAzFirewallSplat = @{
    Name = 'fw-01-p-eus'
    ResourceGroupName = $rg
    Location = $location
    VirtualNetwork = $testvnet
    PublicIpAddress = $pip
    FirewallPolicyId = $policy.id
}

New-AzFirewall @newAzFirewallSplat

# Create the route table
$newAzRouteTableSplat = @{
    Name = 'Firewall-rt-table'
    ResourceGroupName = "$rg"
    Location = $location
    DisableBgpRoutePropagation = $true
}

$routeTableDG = New-AzRouteTable @newAzRouteTableSplat

# Add the default route
$addAzRouteConfigSplat = @{
    Name = "DG-Route"
    RouteTable = $routeTableDG
    AddressPrefix = '0.0.0.0/0'
    NextHopType = "VirtualAppliance"
    NextHopIpAddress = $pip.ipaddress
}

Add-AzRouteConfig @addAzRouteConfigSplat | Set-AzRouteTable

 $newAzStorageAccountSplat = @{
    ResourceGroupName = $rg
    Name = $StorageAccountName
    SkuName = 'Standard_LRS'
    Location = $location
    EnableHierarchicalNamespace = $true
    PublicNetworkAccess = 'enabled'
}

New-AzStorageAccount @newAzStorageAccountSplat

 # Get the subscription and user information
 $subscriptionId = (Get-AzSubscription -SubscriptionName "$SubscriptionName").SubscriptionId
 $user = Get-AzADUser -UserPrincipalName $UserPrincipalName

 # Give the user contributor role
 $newAzRoleAssignmentSplat = @{
    ObjectId = $user.id
    RoleDefinitionName = "Storage Blob Data Contributor"
    Scope = "/subscriptions/$subscriptionId/resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/$StorageAccountName"
}

New-AzRoleAssignment @newAzRoleAssignmentSplat

 #Create the container and then disable public network access
 $ctx = New-AzStorageContext -StorageAccountName $StorageAccountName
 New-AzStorageContainer -Name $ContainerName -Context $ctx
 Set-AzStorageAccount -ResourceGroupName $rg -Name $StorageAccountName -PublicNetworkAccess disabled -Force

 Set-AzStorageAccount -ResourceGroupName $rg -Name $StorageAccountName -EnableSftp $true

$permissionScopeBlob = New-AzStorageLocalUserPermissionScope -Permission rwdlc -Service blob -ResourceName $ContainerName

# $localuser =
$setAzStorageLocalUserSplat = @{
    ResourceGroupName = $rg
    StorageAccountName = $StorageAccountName
    UserName = 'sconnea'
    PermissionScope = $permissionScopeBlob
}

Set-AzStorageLocalUser @setAzStorageLocalUserSplat

$newAzStorageLocalUserSshPasswordSplat = @{
    ResourceGroupName = $rg
    StorageAccountName = $StorageAccountName
    UserName = 'sconnea'
}

$localuserPassword = New-AzStorageLocalUserSshPassword @newAzStorageLocalUserSshPasswordSplat

# Examine and manually save the password

$localuserPassword

# Place the previously created storage account into a variable
$storage = Get-AzStorageAccount -ResourceGroupName $rg -Name $StorageAccountName

# Create the private endpoint connection
$pec = @{
    Name = 'Connection01'
    PrivateLinkServiceId = $storage.ID
    GroupID = 'blob'
}

$privateEndpointConnection = New-AzPrivateLinkServiceConnection @pec


# Create the static IP configuration
$ip = @{
    Name = 'myIPconfig'
    GroupId = 'blob'
    MemberName = 'blob'
    PrivateIPAddress = $staticEP
}

$ipconfig = New-AzPrivateEndpointIpConfiguration @ip

# Create the private endpoint
$pe = @{
    ResourceGroupName = $rg
    Name = 'StorageEP'
    Location = 'eastus'
    Subnet = $testvnet.Subnets[1]
    PrivateLinkServiceConnection = $privateEndpointConnection
    IpConfiguration = $ipconfig
}

New-AzPrivateEndpoint @pe
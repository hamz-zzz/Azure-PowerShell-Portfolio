# Load Balancer configuration
$LoadBalancerName = 'lb-web'

# Resource configuration
$ResourceGroupName = 'rg-compute-web'
$VirtualNetworkName = 'vnet-compute-web'
$SubnetName = 'snet-web'

# Outbound rule configuration
$WindowsOutboundRuleName = 'outbound-windows'
$LinuxOutboundRuleName = 'outbound-linux'
$WindowsFrontendName = 'fe-windows'
$LinuxFrontendName = 'fe-linux'
$WindowsBackendPoolName = 'bepool-windows'
$LinuxBackendPoolName = 'bepool-linux'

# Retrieve Load Balancer
$LoadBalancer = Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName

# Retrieve frontend configurations
$WindowsFrontend = $LoadBalancer.FrontendIpConfigurations | Where-Object Name -eq $WindowsFrontendName
$LinuxFrontend = $LoadBalancer.FrontendIpConfigurations | Where-Object Name -eq $LinuxFrontendName

# Retrieve backend pools
$WindowsBackendPool = $LoadBalancer.BackendAddressPools | Where-Object Name -eq $WindowsBackendPoolName
$LinuxBackendPool = $LoadBalancer.BackendAddressPools | Where-Object Name -eq $LinuxBackendPoolName

# Create outbound rules
Add-AzLoadBalancerOutboundRuleConfig -LoadBalancer $LoadBalancer -Name $WindowsOutboundRuleName -FrontendIpConfiguration $WindowsFrontend -BackendAddressPool $WindowsBackendPool -Protocol All -AllocatedOutboundPort 1024
Add-AzLoadBalancerOutboundRuleConfig -LoadBalancer $LoadBalancer -Name $LinuxOutboundRuleName -FrontendIpConfiguration $LinuxFrontend -BackendAddressPool $LinuxBackendPool -Protocol All -AllocatedOutboundPort 1024

# Update Load Balancer
Set-AzLoadBalancer -LoadBalancer $LoadBalancer

# Disable default outbound access on subnet
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq $SubnetName
Set-AzVirtualNetworkSubnetConfig -Name $Subnet.Name -VirtualNetwork $VirtualNetwork -AddressPrefix $Subnet.AddressPrefix -NetworkSecurityGroup $Subnet.NetworkSecurityGroup -DefaultOutboundAccess $false
Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork

# Verify outbound rules
$LoadBalancer = Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName
$LoadBalancer.OutboundRules

# Verify subnet configuration
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq $SubnetName
$Subnet | Select-Object DefaultOutboundAccess
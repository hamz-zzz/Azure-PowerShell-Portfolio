# Resource configuration
$RouteTableName = 'rt-workload'
$ResourceGroupName = 'rg-network-workload'
$Location = 'eastus2'

# Network configuration
$VirtualNetworkName = 'vnet-workload'
$SubnetName = 'snet-workload'

# Route configuration
$RouteName = 'route-to-internet'
$AddressPrefix = '0.0.0.0/0'
$NextHopType = 'VirtualAppliance'

# Azure Firewall configuration
$FirewallName = 'azfw-hub'
$FirewallResourceGroupName = 'rg-network-hub'

# Retrieve Azure Firewall
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $FirewallResourceGroupName

# Retrieve firewall private IP address
$FirewallPrivateIP = $Firewall.IpConfigurations[0].PrivateIpAddress

# Create route table
$RouteTable = New-AzRouteTable -Name $RouteTableName -ResourceGroupName $ResourceGroupName -Location $Location

# Create default route
Add-AzRouteConfig -Name $RouteName -AddressPrefix $AddressPrefix -NextHopType $NextHopType -NextHopIpAddress $FirewallPrivateIP -RouteTable $RouteTable

# Apply route configuration
Set-AzRouteTable -RouteTable $RouteTable

# Retrieve workload VNet
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Associate route table with workload subnet
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq $SubnetName
Set-AzVirtualNetworkSubnetConfig -Name $Subnet.Name -VirtualNetwork $VirtualNetwork -RouteTable $RouteTable -AddressPrefix $Subnet.AddressPrefix -NetworkSecurityGroup $Subnet.NetworkSecurityGroup

# Apply updated VNet configuration
Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork

# Verify route table
Get-AzRouteTable -Name $RouteTableName -ResourceGroupName $ResourceGroupName | Format-Table Name, Location
(Get-AzRouteTable -Name $RouteTableName -ResourceGroupName $ResourceGroupName).Routes | Format-Table Name, AddressPrefix, NextHopType, NextHopIpAddress
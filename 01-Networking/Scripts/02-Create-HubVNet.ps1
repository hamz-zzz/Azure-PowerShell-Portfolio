# Virtual network configuration
$VirtualNetworkName = 'vnet-hub'
$ResourceGroupName = 'rg-network-hub'
$Location = 'eastus2'
$AddressSpace = '10.0.0.0/16'

# Subnet configuration
$FirewallSubnet = New-AzVirtualNetworkSubnetConfig -Name 'AzureFirewallSubnet' -AddressPrefix '10.0.0.0/26'
$FirewallManagementSubnet = New-AzVirtualNetworkSubnetConfig -Name 'AzureFirewallManagementSubnet' -AddressPrefix '10.0.0.64/26'
$BastionSubnet = New-AzVirtualNetworkSubnetConfig -Name 'AzureBastionSubnet' -AddressPrefix '10.0.0.128/26'

# Create virtual network
$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $AddressSpace -Subnet $FirewallSubnet, $FirewallManagementSubnet, $BastionSubnet

# Verify deployment
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$VirtualNetwork.AddressSpace | Format-Table AddressPrefixes
$VirtualNetwork.Subnets | Format-Table Name, AddressPrefix
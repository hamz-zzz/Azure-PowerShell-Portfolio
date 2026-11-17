# Virtual network configuration
$VirtualNetworkName = 'vnet-workload'
$ResourceGroupName = 'rg-network-workload'
$Location = 'eastus2'
$AddressSpace = '10.1.0.0/16'

# Subnet configuration
$WorkloadSubnet = New-AzVirtualNetworkSubnetConfig -Name 'snet-workload' -AddressPrefix '10.1.0.0/24'

# Create virtual network
$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $AddressSpace -Subnet $WorkloadSubnet

# Verify deployment
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$VirtualNetwork.AddressSpace | Format-Table AddressPrefixes
$VirtualNetwork.Subnets | Format-Table Name, AddressPrefix
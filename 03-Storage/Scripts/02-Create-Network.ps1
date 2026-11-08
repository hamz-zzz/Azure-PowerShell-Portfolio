# Resource configuration
$ResourceGroupName = 'rg-storage'
$Location = 'eastus2'

# Virtual network configuration
$VirtualNetworkName = 'vnet-storage'
$VirtualNetworkAddressPrefix = '10.0.0.0/16'

# Subnet configuration
$SubnetName = 'snet-storage'
$SubnetAddressPrefix = '10.0.0.0/24'

# Create subnet configuration
$Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix

# Create virtual network
New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VirtualNetworkAddressPrefix -Subnet $Subnet

# Verify Deployment
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$VirtualNetwork | Format-List Name, Location
$VirtualNetwork.AddressSpace | Format-List AddressPrefixes
$VirtualNetwork.Subnets | Format-List Name, AddressPrefix
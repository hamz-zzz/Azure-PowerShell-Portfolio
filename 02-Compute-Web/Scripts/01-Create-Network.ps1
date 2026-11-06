# Resource group configuration
$ResourceGroupName = 'rg-compute-web'
$Location = 'eastus2'

# Virtual network configuration
$VirtualNetworkName = 'vnet-compute-web'
$VirtualNetworkAddressPrefix = '10.0.0.0/16'

# Subnet configuration
$SubnetName = 'snet-web'
$SubnetAddressPrefix = '10.0.0.0/24'

# Create resource group
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

# Create subnet configuration
# Include DefaultOutboundAccess
$Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix -DefaultOutboundAccess $true


# Create virtual network
New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VirtualNetworkAddressPrefix -Subnet $Subnet

# Verify virtual network configuration
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$VirtualNetwork | Format-List Name, Location
$VirtualNetwork.AddressSpace | Format-List AddressPrefixes
$VirtualNetwork.Subnets | Format-List Name, AddressPrefix, DefaultOutboundAccess
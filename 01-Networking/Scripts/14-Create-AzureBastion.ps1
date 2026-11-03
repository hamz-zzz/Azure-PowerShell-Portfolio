# Resource configuration
$ResourceGroupName = 'rg-network-hub'
$Location = 'eastus2'

# Virtual network configuration
$VNetName = 'vnet-hub'
$BastionSubnetName = 'AzureBastionSubnet'

# Public IP configuration
$PublicIPName = 'pip-bastion-hub'
$PublicIPSku = 'Standard'
$PublicIPAllocationMethod = 'Static'

# Azure Bastion configuration
$BastionName = 'bas-hub'
$BastionSku = 'Basic'

# Retrieve hub virtual network
# Hint: Get-AzVirtualNetwork

# Retrieve Bastion subnet
# Hint: Get subnet from $VNet.Subnets

# Create public IP address
# Hint: New-AzPublicIpAddress

# Deploy Azure Bastion
# Hint: New-AzBastion
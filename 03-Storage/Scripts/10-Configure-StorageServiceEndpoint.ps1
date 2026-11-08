# Resource configuration
$ResourceGroupName = 'rg-storage'

# Virtual network configuration
$VirtualNetworkName = 'vnet-storage'
$SubnetName = 'snet-storage'

# Storage account configuration
$StorageAccountName = 'storagehm2k'

# Retrieve virtual network
# Hint: Get-AzVirtualNetwork

# Retrieve subnet
# Hint: Get subnet from $VirtualNetwork.Subnets

# Enable Microsoft.Storage service endpoint
# Hint: Set-AzVirtualNetworkSubnetConfig
# Preserve the existing subnet address prefix and NSG association

# Apply virtual network configuration
# Hint: Set-AzVirtualNetwork

# Add subnet to Storage Account network rules
# Hint: Add-AzStorageAccountNetworkRule -VirtualNetworkResourceId

# Set Storage Account default network action to Deny
# Hint: Update-AzStorageAccountNetworkRuleSet -DefaultAction Deny

# Verify Deployment
# Hint: Get-AzVirtualNetwork
# Hint: Get-AzStorageAccountNetworkRuleSet
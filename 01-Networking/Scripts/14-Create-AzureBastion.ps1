# Resource configuration
$ResourceGroupName = 'rg-network-hub'
$Location = 'eastus2'

# Virtual network configuration
$VirtualNetworkName = 'vnet-hub'
$BastionSubnetName = 'AzureBastionSubnet'

# Public IP configuration
$PublicIPName = 'pip-bastion-hub'
$PublicIPSku = 'Standard'
$PublicIPAllocationMethod = 'Static'

# Azure Bastion configuration
$BastionName = 'bastion-hub'
$BastionSku = 'Basic'

# Retrieve hub virtual network
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Retrieve Bastion subnet
$BastionSubnet = $VirtualNetwork.Subnets | Where-Object { $_.Name -eq $BastionSubnetName }

if ($null -eq $BastionSubnet) {
    throw "Subnet '$BastionSubnetName' was not found in '$VirtualNetworkName'."
}

# Create public IP address
$PublicIP = New-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -Sku $PublicIPSku -AllocationMethod $PublicIPAllocationMethod

# Deploy Azure Bastion
$Bastion = New-AzBastion -Name $BastionName -ResourceGroupName $ResourceGroupName -Sku $BastionSku -PublicIpAddress $PublicIP -VirtualNetwork $VirtualNetwork

# Verify Azure Bastion deployment
$Bastion = Get-AzBastion -Name $BastionName -ResourceGroupName $ResourceGroupName
$Bastion | Format-List Name, ProvisioningState
$Bastion.Sku | Format-List
# Resource configuration
$ResourceGroupName = 'rg-storage'
$VirtualNetworkName = 'vnet-storage'
$SubnetName = 'snet-storage'
$StorageAccountName = 'storagehm2k'

# Retrieve virtual network
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Retrieve subnet
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq $SubnetName

# Enable Microsoft.Storage service endpoint
Set-AzVirtualNetworkSubnetConfig -Name $Subnet.Name -VirtualNetwork $VirtualNetwork -AddressPrefix $Subnet.AddressPrefix -NetworkSecurityGroup $Subnet.NetworkSecurityGroup -ServiceEndpoint Microsoft.Storage

# Apply virtual network configuration
Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork

# Add subnet to Storage Account network rules
Add-AzStorageAccountNetworkRule -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -VirtualNetworkResourceId $Subnet.Id

# Set Storage Account default network action to Deny
Update-AzStorageAccountNetworkRuleSet -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -DefaultAction Deny

# Verify Deployment
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
($VirtualNetwork.Subnets | Where-Object Name -eq $SubnetName).ServiceEndpoints
(Get-AzStorageAccountNetworkRuleSet -Name $StorageAccountName -ResourceGroupName $ResourceGroupName).VirtualNetworkRules | Select-Object Action, @{Name = 'Subnet'; Expression = { Split-Path $_.VirtualNetworkResourceId -Leaf }}
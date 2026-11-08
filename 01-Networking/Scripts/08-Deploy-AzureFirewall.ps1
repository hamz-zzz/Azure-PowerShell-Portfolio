# Resource configuration
$FirewallName = 'azfw-hub'
$ResourceGroupName = 'rg-network-hub'
$Location = 'eastus2'

# Public IP configuration
$FirewallPublicIPName = 'pip-azfw-hub'
$ManagementPublicIPName = 'pip-azfw-management-hub'

# Retrieve hub virtual network
$HubVNetName = 'vnet-hub'
$HubVNet = Get-AzVirtualNetwork -Name $HubVNetName -ResourceGroupName $ResourceGroupName

# Create primary firewall public IP
$FirewallPublicIP = New-AzPublicIpAddress -Name $FirewallPublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Static

# Create firewall management public IP
$ManagementPublicIP = New-AzPublicIpAddress -Name $ManagementPublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Static

# Create Azure Firewall
$Firewall = New-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName -Location $Location -VirtualNetwork $HubVNet -PublicIpAddress $FirewallPublicIP -ManagementPublicIpAddress $ManagementPublicIP -SkuTier Basic

# Verify firewall deployment
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName
$Firewall | Format-Table Name, Location, ProvisioningState
$Firewall.IpConfigurations | Format-Table Name, PrivateIpAddress
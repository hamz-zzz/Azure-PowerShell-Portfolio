# Resource group configuration
$ResourceGroupName = 'rg-compute-web'

# Network security group configuration
$NSGName = 'nsg-web'
$Location = 'eastus2'

# Virtual network configuration
$VirtualNetworkName = 'vnet-compute-web'

# Subnet configuration
$SubnetName = 'snet-web'

# HTTP security rule configuration
$HTTPRuleName = 'Allow-HTTP'

# Create HTTP security rule
$HTTPRule = New-AzNetworkSecurityRuleConfig -Name $HTTPRuleName -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Protocol Tcp -Access Allow -Priority 100 -Direction Inbound

# Create network security group
# Hint: New-AzNetworkSecurityGroup
$NSG = New-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName -Location $Location -SecurityRules $HTTPRule

# Retrieve virtual network
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Associate NSG with subnet
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork
Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork -AddressPrefix $Subnet.AddressPrefix -NetworkSecurityGroup $NSG
Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork

# Verify NSG configuration
Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$VirtualNetwork.Subnets | Select-Object Name, AddressPrefix, @{Name = 'NSG'; Expression = { $_.NetworkSecurityGroup.Id } }
(Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName).SecurityRules | Format-Table Name, Priority, Direction, Access, Protocol, SourceAddressPrefix, SourcePortRange, DestinationAddressPrefix, DestinationPortRange
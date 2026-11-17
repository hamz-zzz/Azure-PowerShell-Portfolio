# Resource configuration
$ResourceGroupName = 'rg-storage'
$Location = 'eastus2'

# Network configuration
$VirtualNetworkName = 'vnet-storage'
$SubnetName = 'snet-storage'
$AdminPublicIP = Invoke-RestMethod https://api.ipify.org

# Network security group configuration
$NSGName = 'nsg-storage'
$RuleName = 'Allow-RDP'

# Create network security rule
$Rule = New-AzNetworkSecurityRuleConfig -Name $RuleName -Priority 100 -Protocol Tcp -SourceAddressPrefix "$AdminPublicIP/32" -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow -Direction Inbound

# Create network security group
$NSG = New-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName -Location $Location -SecurityRules $Rule

# Retrieve virtual network and subnet
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq $SubnetName

# Associate NSG with subnet
Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork -AddressPrefix $Subnet.AddressPrefix -NetworkSecurityGroup $NSG

# Apply virtual network configuration
Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork

# Verify Deployment
Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$VirtualNetwork.Subnets | Select-Object Name, AddressPrefix, @{Name = 'NSG'; Expression = { Split-Path $_.NetworkSecurityGroup.Id -LeafBase } }
(Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName).SecurityRules | Format-Table Name, Priority, Direction, Access, Protocol, SourceAddressPrefix, SourcePortRange, DestinationAddressPrefix, DestinationPortRange
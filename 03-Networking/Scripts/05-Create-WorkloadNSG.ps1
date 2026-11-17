# Network security group configuration
$NSGName = 'nsg-workload'
$ResourceGroupName = 'rg-network-workload'
$Location = 'eastus2'
$VirtualNetworkName = 'vnet-workload'
$SubnetName = 'snet-workload'
$BastionAddressPrefix = '10.0.0.128/26'
$WorkloadAddressPrefix = '10.1.0.0/24'

# Create inbound security rules

# Allow Bastion RDP (TCP 3389)
$AllowBastionRDP = New-AzNetworkSecurityRuleConfig -Name 'Allow-Bastion-RDP' -Priority 100 -Direction Inbound -Access Allow -Protocol Tcp -SourceAddressPrefix $BastionAddressPrefix -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

# Allow Bastion SSH (TCP 22)
$AllowBastionSSH = New-AzNetworkSecurityRuleConfig -Name 'Allow-Bastion-SSH' -Priority 110 -Direction Inbound -Access Allow -Protocol Tcp -SourceAddressPrefix $BastionAddressPrefix -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22

# Allow communication between workload VMs
$AllowWorkloadInternal = New-AzNetworkSecurityRuleConfig -Name 'Allow-Workload-Internal' -Priority 120 -Direction Inbound  -Access Allow -Protocol * -SourceAddressPrefix $WorkloadAddressPrefix -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

# Deny other VNet inbound traffic
$DenyOtherVNetInbound = New-AzNetworkSecurityRuleConfig -Name 'Deny-Other-VNet-Inbound' -Priority 200 -Direction Inbound -Access Deny -Protocol * -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

# Create network security group
$NetworkSecurityGroup = New-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName -Location $Location -SecurityRules $AllowBastionRDP, $AllowBastionSSH, $AllowWorkloadInternal, $DenyOtherVNetInbound

# Retrieve workload VNet
$WorkloadVNet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Associate NSG with workload subnet
Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $WorkloadVNet -AddressPrefix $WorkloadAddressPrefix -NetworkSecurityGroup $NetworkSecurityGroup

# Apply updated VNet configuration
Set-AzVirtualNetwork -VirtualNetwork $WorkloadVNet

# Verify NSG configuration
Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName
$WorkloadVNet.Subnets | Select-Object Name, AddressPrefix, @{Name = 'NSG'; Expression = { $_.NetworkSecurityGroup.Id } }
(Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName).SecurityRules | Format-Table Name, Priority, Direction, Access, Protocol, SourceAddressPrefix, SourcePortRange, DestinationAddressPrefix, DestinationPortRange
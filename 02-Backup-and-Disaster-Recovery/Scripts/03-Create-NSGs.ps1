# Resource configuration
$AdminPublicIP = Invoke-RestMethod -Uri 'https://api.ipify.org'

$NetworkSecurityGroups = @(
    @{
        Name           = 'nsg-primary'
        ResourceGroup  = 'rg-recovery-primary'
        Location       = 'eastus2'
        VirtualNetwork = 'vnet-primary'
        Subnet         = 'snet-primary'
    }
    @{
        Name           = 'nsg-secondary'
        ResourceGroup  = 'rg-recovery-secondary'
        Location       = 'centralus'
        VirtualNetwork = 'vnet-secondary'
        Subnet         = 'snet-secondary'
    }
)

foreach ($NetworkSecurityGroup in $NetworkSecurityGroups) {

    # Create security rules
    $RDPRule = New-AzNetworkSecurityRuleConfig -Name 'Allow-RDP' -Direction Inbound -Access Allow -SourceAddressPrefix "$AdminPublicIP/32" -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 3389 -Protocol Tcp -Priority 100
    $HTTPRule = New-AzNetworkSecurityRuleConfig -Name 'Allow-HTTP' -Direction Inbound -Access Allow -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 80 -Protocol Tcp -Priority 110

    # Create NSG
    $NSG = New-AzNetworkSecurityGroup -Name $NetworkSecurityGroup.Name -ResourceGroupName $NetworkSecurityGroup.ResourceGroup -Location $NetworkSecurityGroup.Location -SecurityRules $RDPRule, $HTTPRule

    # Associate NSGs with Subnets
    $VNet = Get-AzVirtualNetwork -Name $NetworkSecurityGroup.VirtualNetwork -ResourceGroupName $NetworkSecurityGroup.ResourceGroup

    # Update subnet configuration with NSG
    $Subnet = $Vnet.Subnets | Where-Object { $_.Name -eq $NetworkSecurityGroup.Subnet }
    Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNet -Name $Subnet.Name -AddressPrefix $Subnet.AddressPrefix -NetworkSecurityGroup $NSG

    # Save virtual network configuration
    Set-AzVirtualNetwork -VirtualNetwork $VNet
}


# Verify Deployment
foreach ($NetworkSecurityGroup in $NetworkSecurityGroups) {
    $VNet = Get-AzVirtualNetwork -Name $NetworkSecurityGroup.VirtualNetwork -ResourceGroupName $NetworkSecurityGroup.ResourceGroup
    $VNet.Subnets | Select-Object Name, AddressPrefix, @{Name = 'NSG'; Expression = { Split-Path $_.NetworkSecurityGroup.Id -LeafBase } }
    $NSG = Get-AzNetworkSecurityGroup -Name $NetworkSecurityGroup.Name -ResourceGroupName $NetworkSecurityGroup.ResourceGroup
    $NSG | Format-Table
    $NSG.SecurityRules | Format-Table Name, Priority, Direction, Access, Protocol, SourceAddressPrefix, SourcePortRange, DestinationAddressPrefix, DestinationPortRange
}
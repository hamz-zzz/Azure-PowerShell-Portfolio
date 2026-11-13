# Resource configuration
$VirtualNetworks = @(
    @{
        Name = 'vnet-primary'
        ResourceGroup = 'rg-recovery-primary'
        Location = 'eastus2'
        AddressPrefix = '10.0.0.0/16'
        SubnetName = 'snet-primary'
        SubnetPrefix = '10.0.0.0/24'
    }
    @{
        Name = 'vnet-secondary'
        ResourceGroup = 'rg-recovery-secondary'
        Location = 'centralus'
        AddressPrefix = '10.1.0.0/16'
        SubnetName = 'snet-secondary'
        SubnetPrefix = '10.1.0.0/24'
    }
)

# Create Virtual Networks
foreach ($VirtualNetwork in $VirtualNetworks) {

    # Create subnet configuration
    $Subnet = New-AzVirtualNetworkSubnetConfig -Name $VirtualNetwork.SubnetName -AddressPrefix $VirtualNetwork.SubnetPrefix

    # Create virtual network
    New-AzVirtualNetwork -Name $VirtualNetwork.Name -ResourceGroupName $VirtualNetwork.ResourceGroup -Location $VirtualNetwork.Location -AddressPrefix $VirtualNetwork.AddressPrefix -Subnet $Subnet
}

# Verify Deployment
foreach ($VirtualNetwork in $VirtualNetworks) {
    $VNet = Get-AzVirtualNetwork -Name $VirtualNetwork.Name -ResourceGroupName $VirtualNetwork.ResourceGroup
    $VNet | Select-Object Name, Location, ResourceGroupName, @{Name = 'AddressSpace'; Expression = { $_.AddressSpace.AddressPrefixes }} | Format-Table
    $VNet.Subnets | Select-Object Name, AddressPrefix | Format-Table
}
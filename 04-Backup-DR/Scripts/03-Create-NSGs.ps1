
# Resource configuration
$PublicIP = '' # Your current public IP address with /32

$NetworkSecurityGroups = @(
    @{
        Name = 'nsg-primary'
        ResourceGroup = 'rg-recovery-primary'
        Location = 'eastus2'
        VirtualNetwork = 'vnet-primary'
        Subnet = 'snet-primary'
    }
    @{
        Name = 'nsg-secondary'
        ResourceGroup = 'rg-recovery-secondary'
        Location = 'centralus'
        VirtualNetwork = 'vnet-secondary'
        Subnet = 'snet-secondary'
    }
)


# Create Network Security Groups
foreach ($NetworkSecurityGroup in $NetworkSecurityGroups) {

    # Create security rules
    # Hint: New-AzNetworkSecurityRuleConfig
    # RDP - TCP 3389, inbound, allow, source: $PublicIP, priority: 100
    # HTTP - TCP 80, inbound, allow, source: $PublicIP, priority: 110

    # Create NSG
    # Hint: New-AzNetworkSecurityGroup

}


# Associate NSGs with Subnets
foreach ($NetworkSecurityGroup in $NetworkSecurityGroups) {

    # Get virtual network
    # Hint: Get-AzVirtualNetwork

    # Update subnet configuration with NSG
    # Hint: Set-AzVirtualNetworkSubnetConfig

    # Save virtual network configuration
    # Hint: Set-AzVirtualNetwork

}


# Verify Deployment
foreach ($NetworkSecurityGroup in $NetworkSecurityGroups) {

    # Verify NSG and security rules
    # Hint: Get-AzNetworkSecurityGroup

    # Verify subnet association
    # Hint: Get-AzVirtualNetwork
}

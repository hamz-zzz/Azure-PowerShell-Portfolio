# Resource configuration
$ResourceGroupName = 'rg-compute-web'
$LoadBalancerName = 'lb-web'
$NSGName = 'nsg-web'

# Administrative access configuration
$AdminPublicIP = Invoke-RestMethod https://api.ipify.org
$AdminAddressPrefix = "$AdminPublicIP/32"

# Inbound NAT rule configurations
$NATRuleConfigurations = @(
    @{
        Name         = 'nat-win01-rdp'
        FrontendName = 'fe-windows'
        FrontendPort = 50001
        BackendPort  = 3389
    }
    @{
        Name         = 'nat-win02-rdp'
        FrontendName = 'fe-windows'
        FrontendPort = 50002
        BackendPort  = 3389
    }
    @{
        Name         = 'nat-linux01-ssh'
        FrontendName = 'fe-linux'
        FrontendPort = 60001
        BackendPort  = 22
    }
    @{
        Name         = 'nat-linux02-ssh'
        FrontendName = 'fe-linux'
        FrontendPort = 60002
        BackendPort  = 22
    }
)

# Retrieve Load Balancer
$LoadBalancer = Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName

# Create inbound NAT rules
foreach ($NATRule in $NATRuleConfigurations) {
    $Frontend = $LoadBalancer.FrontendIpConfigurations | Where-Object Name -eq $NATRule.FrontendName

    Add-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $LoadBalancer -Name $NATRule.Name -Protocol Tcp -FrontendIpConfiguration $Frontend -FrontendPort $NATRule.FrontendPort -BackendPort $NATRule.BackendPort
}

# Update Load Balancer
Set-AzLoadBalancer -LoadBalancer $LoadBalancer

# Retrieve Load Balancer with updated inbound NAT rules
$LoadBalancer = Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName

# NIC and NAT rule associations
$NATRuleAssociations = @(
    @{
        NetworkInterfaceName = 'nic-web-win01'
        NATRuleName          = 'nat-win01-rdp'
    }
    @{
        NetworkInterfaceName = 'nic-web-win02'
        NATRuleName          = 'nat-win02-rdp'
    }
    @{
        NetworkInterfaceName = 'nic-web-linux01'
        NATRuleName          = 'nat-linux01-ssh'
    }
    @{
        NetworkInterfaceName = 'nic-web-linux02'
        NATRuleName          = 'nat-linux02-ssh'
    }
)

# Associate inbound NAT rules with network interfaces
foreach ($Association in $NATRuleAssociations) {
    # Retrieve network interface
    $NetworkInterface = Get-AzNetworkInterface -Name $Association.NetworkInterfaceName -ResourceGroupName $ResourceGroupName

    # Retrieve inbound NAT rule
    $NATRule = $LoadBalancer.InboundNatRules | Where-Object Name -eq $Association.NATRuleName

    # Associate NAT rule with NIC IP configuration
    $NetworkInterface.IpConfigurations[0].LoadBalancerInboundNatRules.Add($NATRule)

    # Update network interface
    Set-AzNetworkInterface -NetworkInterface $NetworkInterface
}

# Retrieve network security group
$NSG = Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName

# Create RDP and SSH security rules
Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG -Name 'Allow-RDP-Admin' -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix $AdminAddressPrefix -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow
Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG -Name 'Allow-SSH-Admin' -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix $AdminAddressPrefix -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access Allow

# Update network security group
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSG

# Verify inbound NAT rules
$LoadBalancer = Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName
$LoadBalancer.InboundNatRules

# Verify NIC and inbound NAT rule associations
$NetworkInterfaceNames = 'nic-web-win01', 'nic-web-win02', 'nic-web-linux01', 'nic-web-linux02'
foreach ($NetworkInterfaceName in $NetworkInterfaceNames) {
    Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName |
    Select-Object Name, @{N = 'InboundNATRules'; E = { Split-Path $_.IpConfigurations.LoadBalancerInboundNatRules.Id -Leaf } }
}

# Verify NSG security rules
(Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName).SecurityRules | Format-Table Name, Priority, Direction, Access, Protocol, SourceAddressPrefix, SourcePortRange, DestinationAddressPrefix, DestinationPortRange
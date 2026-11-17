# Load Balancer configuration
$LoadBalancerName = 'lb-web'
$ResourceGroupName = 'rg-compute-web'

# Health probe configuration
$WindowsProbeName = 'probe-windows-http'
$LinuxProbeName = 'probe-linux-http'
$ProbeRequestPath = '/'

# Load balancing rule configuration
$WindowsRuleName = 'rule-windows-http'
$LinuxRuleName = 'rule-linux-http'

# Retrieve Load Balancer
$LoadBalancer = Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName

# Retrieve frontend configurations
$WindowsFrontend = $LoadBalancer.FrontendIpConfigurations | Where-Object Name -eq 'fe-windows'
$LinuxFrontend = $LoadBalancer.FrontendIpConfigurations | Where-Object Name -eq 'fe-linux'

# Retrieve backend pools
$WindowsBackendPool = $LoadBalancer.BackendAddressPools | Where-Object Name -eq 'bepool-windows'
$LinuxBackendPool = $LoadBalancer.BackendAddressPools | Where-Object Name -eq 'bepool-linux'

# Retrieve Windows network interfaces
$WindowsNetworkInterfaces = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName | Where-Object Name -like '*nic-web-win0*'

# Retrieve Linux network interfaces
$LinuxNetworkInterfaces = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName | Where-Object Name -like '*nic-web-linux0*'

# Associate Windows NICs with backend pool
foreach ($NetworkInterface in $WindowsNetworkInterfaces) {
        $NetworkInterface.IpConfigurations[0].LoadBalancerBackendAddressPools.Add($WindowsBackendPool)
        Set-AzNetworkInterface -NetworkInterface $NetworkInterface
}

# Associate Linux NICs with backend pool
foreach ($NetworkInterface in $LinuxNetworkInterfaces) {
        $NetworkInterface.IpConfigurations[0].LoadBalancerBackendAddressPools.Add($LinuxBackendPool)
        Set-AzNetworkInterface -NetworkInterface $NetworkInterface
}

# Create health probes
Add-AzLoadBalancerProbeConfig -LoadBalancer $LoadBalancer -Name $WindowsProbeName -Protocol Http -Port 80 -RequestPath $ProbeRequestPath -IntervalInSeconds 5 -ProbeCount 2
Add-AzLoadBalancerProbeConfig -LoadBalancer $LoadBalancer -Name $LinuxProbeName -Protocol Http -Port 80 -RequestPath $ProbeRequestPath -IntervalInSeconds 5 -ProbeCount 2

# Retrieve health probes
$WindowsProbe = $LoadBalancer.Probes | Where-Object Name -eq $WindowsProbeName
$LinuxProbe = $LoadBalancer.Probes | Where-Object Name -eq $LinuxProbeName

# Create inbound load balancing rules
Add-AzLoadBalancerRuleConfig -LoadBalancer $LoadBalancer -Name $WindowsRuleName -Protocol Tcp -FrontendPort 80 -BackendPort 80 -FrontendIpConfiguration $WindowsFrontend -BackendAddressPool $WindowsBackendPool -Probe $WindowsProbe -DisableOutboundSNAT

Add-AzLoadBalancerRuleConfig -LoadBalancer $LoadBalancer -Name $LinuxRuleName -Protocol Tcp -FrontendPort 80 -BackendPort 80 -FrontendIpConfiguration $LinuxFrontend -BackendAddressPool $LinuxBackendPool -Probe $LinuxProbe -DisableOutboundSNAT

# Update Load Balancer
Set-AzLoadBalancer -LoadBalancer $LoadBalancer

# Verify backend pool associations
Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName | Where-Object Name -like '*nic-web-*' | Select-Object Name, @{N = 'BackendPools'; E = { $_.IpConfigurations[0].LoadBalancerBackendAddressPools.Id | ForEach-Object { Split-Path $_ -Leaf } }}

# Verify health probes and load balancing rules
$LoadBalancer = Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName
$LoadBalancer.Probes | Format-Table Name, Protocol, Port, RequestPath, ProvisioningState
$LoadBalancer.LoadBalancingRules | Format-Table Name, Protocol, FrontendPort, BackendPort, ProvisioningState
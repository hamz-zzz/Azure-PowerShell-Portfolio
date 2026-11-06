# Load Balancer configuration
$LoadBalancerName = 'lb-web'
$Location = 'eastus2'

# Resource configuration
$ResourceGroupName = 'rg-compute-web'

# Public IP configuration
$WindowsPublicIPName = 'pip-lb-windows'
$LinuxPublicIPName = 'pip-lb-linux'

# Frontend configuration
$WindowsFrontendName = 'fe-windows'
$LinuxFrontendName = 'fe-linux'

# Backend pool configuration
$WindowsBackendPoolName = 'bepool-windows'
$LinuxBackendPoolName = 'bepool-linux'

# Create public IP addresses
$WindowsPublicIP = New-AzPublicIpAddress -Name $WindowsPublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -Sku Standard -AllocationMethod Static
$LinuxPublicIP = New-AzPublicIpAddress -Name $LinuxPublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -Sku Standard -AllocationMethod Static

# Create Load Balancer frontend configurations
$WindowsFrontend = New-AzLoadBalancerFrontendIpConfig -Name $WindowsFrontendName -PublicIpAddress $WindowsPublicIP
$LinuxFrontend = New-AzLoadBalancerFrontendIpConfig -Name $LinuxFrontendName -PublicIpAddress $LinuxPublicIP

# Create Load Balancer backend address pools
$WindowsBackendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $WindowsBackendPoolName
$LinuxBackendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $LinuxBackendPoolName

# Create Load Balancer
New-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName -Location $Location -Sku Standard -Tier Regional -FrontendIpConfiguration $WindowsFrontend, $LinuxFrontend -BackendAddressPool $WindowsBackendPool, $LinuxBackendPool

# Verify public IP addresses
Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName | Where-Object Name -in $WindowsPublicIPName, $LinuxPublicIPName | Format-Table Name, Location, @{N = 'SKU'; E = { $_.Sku.Name }}, PublicIpAllocationMethod, IpAddress

# Verify Load Balancer
Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName | Format-List Name, Location, @{N = 'SKU'; E = { $_.Sku.Name }}, ProvisioningState
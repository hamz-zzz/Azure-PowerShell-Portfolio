# Load Balancer configuration
$LoadBalancerName = 'lb-web'
$Location = 'eastus2'

# Resource configuration
$ResourceGroupName = 'rg-compute-web'

# Public IP configuration
$PublicIPNames = 'pip-lb-windows', 'pip-lb-linux'

# Frontend configuration
$FrontendNames = 'fe-windows', 'fe-linux'

# Backend pool configuration
$BackendPoolNames = 'bepool-windows', 'bepool-linux'

# Create public IP addresses
# New-AzPublicIpAddress
$PublicIPAddresses += foreach ($PublicIPName in $PublicIPNames) {
    New-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -Sku Standard -AllocationMethod Static
}

# Create Load Balancer frontend configurations
$FrontendIpConfigurations = for ($i = 0; $i -lt $FrontendNames.Count; $i++) {
    New-AzLoadBalancerFrontendIpConfig -Name $FrontendNames[$i] -PublicIpAddress $PublicIPAddresses[$i]
}

# Create Load Balancer backend address pools
$BackendAddressPools = foreach ($BackendPoolName in $BackendPoolNames) {
    New-AzLoadBalancerBackendAddressPoolConfig -Name $BackendPoolName
}
# Create Load Balancer
# New-AzLoadBalancer
New-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName -Location $Location -Sku Standard -Tier Regional -FrontendIpConfiguration $FrontendIpConfigurations -BackendAddressPool $BackendAddressPools

# Verify public IP addresses
Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName | Where-Object Name -in $PublicIPNames | Format-Table Name, Location, @{N='SKU'; E={$_.Sku.Name}}, PublicIpAllocationMethod, IpAddress

# Verify Load Balancer
Get-AzLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ResourceGroupName | Format-List Name, Location, @{N='SKU'; E={$_.Sku.Name}}, ProvisioningState
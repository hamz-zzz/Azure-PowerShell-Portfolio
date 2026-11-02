# Resource configuration
$FirewallName = 'azfw-hub'
$ResourceGroupName = 'rg-network-hub'
$HubVNetName = 'vnet-hub'

# Route configuration
$RouteTableName = 'rt-workload'
$RouteName = 'route-to-internet'
$AddressPrefix = '0.0.0.0/0'
$NextHopType = 'VirtualAppliance'
$RouteTableResourceGroupName = 'rg-network-workload'

# Public IP configuration
$FirewallPublicIPName = 'pip-azfw-hub'
$ManagementPublicIPName = 'pip-azfw-management-hub'
$Location = 'eastus2'

# Retrieve Azure Firewall
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Retrieve hub virtual network
$HubVNet = Get-AzVirtualNetwork -Name $HubVNetName -ResourceGroupName $ResourceGroupName

# Create primary firewall public IP
$FirewallPublicIP = New-AzPublicIpAddress -Name $FirewallPublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Static

# Create management public IP
$ManagementPublicIP = New-AzPublicIpAddress -Name $ManagementPublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Static

# Allocate Azure Firewall Basic
$Firewall.AllocateBasicSku($HubVNet, @($FirewallPublicIP), $ManagementPublicIP)

# Apply updated firewall configuration
Set-AzFirewall -AzureFirewall $Firewall

# Retrieve updated firewall configuration
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Retrieve current firewall private IP
$FirewallPrivateIP = $Firewall.IpConfigurations[0].PrivateIpAddress

# Retrieve workload route table
$RouteTable = Get-AzRouteTable -Name $RouteTableName -ResourceGroupName $RouteTableResourceGroupName

# Retrieve existing route
$Route = $RouteTable.Routes | Where-Object Name -eq $RouteName

# Update route next-hop IP if necessary
if ($Route.NextHopIpAddress -ne $FirewallPrivateIP) {
    Set-AzRouteConfig -Name $RouteName -AddressPrefix $AddressPrefix -NextHopType $NextHopType -NextHopIpAddress $FirewallPrivateIP -RouteTable $RouteTable
    Set-AzRouteTable -RouteTable $RouteTable
}

# Verify firewall allocation
if ($Firewall.IpConfigurations.Count -gt 0) {
    Write-Host 'Azure Firewall is allocated.' -ForegroundColor Green
}
else {
    Write-Host 'Azure Firewall is not allocated.' -ForegroundColor Red
}

# Retrieve updated route
$RouteTable = Get-AzRouteTable -Name $RouteTableName -ResourceGroupName $RouteTableResourceGroupName
$Route = $RouteTable.Routes | Where-Object Name -eq $RouteName

# Verify route configuration
$Route | Format-Table Name, AddressPrefix, NextHopType, NextHopIpAddress

# Verify firewall and route table IP addresses
if ($FirewallPrivateIP -eq $Route.NextHopIpAddress) {
    Write-Host 'Firewall and route table IP addresses match.' -ForegroundColor Green
}
else {
    Write-Host 'Firewall and route table IP addresses do not match.' -ForegroundColor Red
}
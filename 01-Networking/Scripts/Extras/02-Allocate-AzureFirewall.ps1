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

# Retrieve Azure Firewall
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Retrieve hub virtual network
$HubVNet = Get-AzVirtualNetwork -Name $HubVNetName -ResourceGroupName $ResourceGroupName

# Retrieve primary firewall public IP
$FirewallPublicIP = Get-AzPublicIpAddress -Name $FirewallPublicIPName -ResourceGroupName $ResourceGroupName

# Retrieve management public IP
$ManagementPublicIP = Get-AzPublicIpAddress -Name $ManagementPublicIPName -ResourceGroupName $ResourceGroupName

# Allocate Azure Firewall Basic
$Firewall.AllocateBasicSku($HubVNet, @($FirewallPublicIP), $ManagementPublicIP)

# Apply updated firewall configuration
# Hint: Set-AzFirewall -AzureFirewall
Set-AzFirewall -AzureFirewall $Firewall

# Retrieve updated firewall configuration
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Retrieve current firewall private IP
$FirewallPrivateIP = $Firewall.IpConfigurations[0].PrivateIpAddress

# Retrieve workload route table
# Hint: Get-AzRouteTable
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
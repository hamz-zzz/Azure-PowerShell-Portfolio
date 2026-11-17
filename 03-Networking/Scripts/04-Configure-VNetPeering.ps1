# Virtual network configuration
$HubVNet = Get-AzVirtualNetwork -Name 'vnet-hub' -ResourceGroupName 'rg-network-hub'
$WorkloadVNet = Get-AzVirtualNetwork -Name 'vnet-workload' -ResourceGroupName 'rg-network-workload'

# Configure hub-to-workload peering
Add-AzVirtualNetworkPeering -VirtualNetwork $HubVNet -RemoteVirtualNetworkId $WorkloadVNet.Id -Name 'hub-workload-peering' -AllowForwardedTraffic

# Configure workload-to-hub peering
Add-AzVirtualNetworkPeering -VirtualNetwork $WorkloadVNet -RemoteVirtualNetworkId $HubVNet.Id -Name 'workload-hub-peering' -AllowForwardedTraffic

# Verify peering configuration
Get-AzVirtualNetworkPeering -VirtualNetwork $HubVNet.Name -ResourceGroupName $HubVNet.ResourceGroupName | Format-Table Name, PeeringState, AllowVirtualNetworkAccess, AllowForwardedTraffic
Get-AzVirtualNetworkPeering -VirtualNetwork $WorkloadVNet.Name -ResourceGroupName $WorkloadVNet.ResourceGroupName | Format-Table Name, PeeringState, AllowVirtualNetworkAccess, AllowForwardedTraffic
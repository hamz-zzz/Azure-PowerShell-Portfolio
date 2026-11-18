# Resource configuration
$ResourceGroupName = 'rg-storage'
$VirtualNetworkName = 'vnet-storage'
$BlobDNSZoneName = 'privatelink.blob.core.windows.net'
$FilesDNSZoneName = 'privatelink.file.core.windows.net'
$BlobDNSLinkName = 'link-blob-storage-vnet'
$FilesDNSLinkName = 'link-file-storage-vnet'

# Retrieve virtual network
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Create Blob Private DNS zone
New-AzPrivateDnsZone -Name $BlobDNSZoneName -ResourceGroupName $ResourceGroupName

# Create Files Private DNS zone
New-AzPrivateDnsZone -Name $FilesDNSZoneName -ResourceGroupName $ResourceGroupName

# Link Blob DNS zone to virtual network
New-AzPrivateDnsVirtualNetworkLink  -Name $BlobDNSLinkName -ZoneName $BlobDNSZoneName -VirtualNetwork $VirtualNetwork -ResourceGroupName $ResourceGroupName

# Link Files DNS zone to virtual network
New-AzPrivateDnsVirtualNetworkLink -Name $FilesDNSLinkName -ZoneName $FilesDNSZoneName -VirtualNetwork $VirtualNetwork -ResourceGroupName $ResourceGroupName

# Verify Deployment
Get-AzPrivateDnsZone -ResourceGroupName $ResourceGroupName | Select-Object Name, NumberOfVirtualNetworkLinks
foreach ($DNSZoneName in $BlobDNSZoneName, $FilesDNSZoneName) { Get-AzPrivateDnsVirtualNetworkLink -ZoneName $DNSZoneName -ResourceGroupName $ResourceGroupName | Select-Object Name, ZoneName, VirtualNetworkLinkState, ProvisioningState }
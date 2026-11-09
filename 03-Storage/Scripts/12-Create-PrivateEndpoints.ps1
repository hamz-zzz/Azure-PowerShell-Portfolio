# Resource configuration
$ResourceGroupName = 'rg-storage'
$Location = 'eastus2'

# Network configuration
$VirtualNetworkName = 'vnet-storage'
$SubnetName = 'snet-storage'

# Storage account configuration
$StorageAccountName = 'storagehm2k'

# Private Endpoint configuration
$BlobConnectionName = 'blob-connection'
$FilesConnectionName = 'files-connection'
$BlobEndpointName = 'private-endpoint-blob'
$FilesEndpointName = 'private-endpoint-files'

# Private DNS configuration
$BlobDNSZoneName = 'privatelink.blob.core.windows.net'
$FilesDNSZoneName = 'privatelink.file.core.windows.net'

# Retrieve virtual network
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Retrieve subnet
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq $SubnetName

# Retrieve storage account
$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName

# Create Blob Private Link service connection
$BlobConnection = New-AzPrivateLinkServiceConnection -Name $BlobConnectionName -PrivateLinkService -GroupId blob

# Create Files Private Link service connection
$FilesConnection = New-AzPrivateLinkServiceConnection -Name $FilesConnectionName -PrivateLinkService -GroupId file

# Create Blob Private Endpoint
New-AzPrivateEndpoint -Name $BlobEndpointName -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet -PrivateLinkServiceConnection $BlobConnection

# Create Files Private Endpoint
New-AzPrivateEndpoint -Name $FilesEndpointName -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet -PrivateLinkServiceConnection $FilesConnection

# Retrieve Private DNS zones
$BlobDNSZone = Get-AzPrivateDnsZone -Name $BlobDNSZoneName -ResourceGroupName $ResourceGroupName
$FilesDNSZone = Get-AzPrivateDnsZone -Name $FilesDNSZoneName -ResourceGroupName $ResourceGroupName

# Create Blob Private DNS zone configuration
$BlobDNSConfig = New-AzPrivateDnsZoneConfig -Name default -PrivateDnsZoneId $BlobDNSZone.ResourceId

# Create Files Private DNS zone configuration
$FilesDNSConfig = New-AzPrivateDnsZoneConfig -Name default -PrivateDnsZoneId $FilesDNSZone.ResourceId

# Associate Blob Private Endpoint with DNS zone
New-AzPrivateDnsZoneGroup -Name default -ResourceGroupName $ResourceGroupName -PrivateEndpointName $BlobEndpointName -PrivateDnsZoneConfig $BlobDNSConfig

# Associate Files Private Endpoint with DNS zone
New-AzPrivateDnsZoneGroup -Name default -ResourceGroupName $ResourceGroupName -PrivateEndpointName $FilesEndpointName -PrivateDnsZoneConfig $FilesDNSConfig

# Verify Deployment
# Hint: Get-AzPrivateEndpoint
# Hint: Get-AzPrivateDnsZoneGroup
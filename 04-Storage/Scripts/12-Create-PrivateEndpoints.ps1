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
$BlobIPConfigName = 'blob-ipconfig'
$FilesIPConfigName = 'files-ipconfig'

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
$BlobConnection = New-AzPrivateLinkServiceConnection -Name $BlobConnectionName -PrivateLinkServiceId $StorageAccount.Id -GroupId blob

# Create Files Private Link service connection
$FilesConnection = New-AzPrivateLinkServiceConnection -Name $FilesConnectionName -PrivateLinkServiceId $StorageAccount.Id -GroupId file

# Create Blob Private Endpoint IP configuration
$BlobIPConfig = New-AzPrivateEndpointIpConfiguration -Name $BlobIPConfigName -GroupId blob -MemberName blob -PrivateIpAddress '10.0.0.5'

# Create Files Private Endpoint IP configuration
$FilesIPConfig = New-AzPrivateEndpointIpConfiguration -Name $FilesIPConfigName -GroupId file -MemberName file -PrivateIpAddress '10.0.0.6'

# Create Blob Private Endpoint
New-AzPrivateEndpoint -Name $BlobEndpointName -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet -PrivateLinkServiceConnection $BlobConnection -IpConfiguration $BlobIPConfig

# Create Files Private Endpoint
New-AzPrivateEndpoint -Name $FilesEndpointName -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet -PrivateLinkServiceConnection $FilesConnection -IpConfiguration $FilesIPConfig

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
foreach ($EndpointName in $BlobEndpointName, $FilesEndpointName) {
    Get-AzPrivateEndpoint -Name $EndpointName -ResourceGroupName $ResourceGroupName | Format-Table Name, ProvisioningState
    $DNSZoneGroup = Get-AzPrivateDnsZoneGroup -PrivateEndpointName $EndpointName -ResourceGroupName $ResourceGroupName
    $DNSZoneGroup.PrivateDnsZoneConfigs.RecordSets | Select-Object RecordSetName, Fqdn, ProvisioningState, IpAddresses
}
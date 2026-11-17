# Resource configuration
$StorageAccountName = 'storagehm2k'
$ContainerName = 'labcontainer'

# Create storage context
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount

# Create Blob container
New-AzStorageContainer -Name $ContainerName -Context $Context

# Verify Deployment
Get-AzStorageContainer -Name $ContainerName -Context $Context
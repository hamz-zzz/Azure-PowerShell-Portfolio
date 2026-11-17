# Resource configuration
$ResourceGroupName = 'rg-storage'
$StorageAccountName = 'storagehm2k'

# Retrieve storage account properties
$BlobProperties = Get-AzStorageBlobServiceProperty -StorageAccountName $StorageAccountName  -ResourceGroupName $ResourceGroupName
$FileProperties = Get-AzStorageFileServiceProperty -StorageAccountName $StorageAccountName  -ResourceGroupName $ResourceGroupName

# Enable Blob versioning
if (-not $BlobProperties.IsVersioningEnabled) {
    Update-AzStorageBlobServiceProperty -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -IsVersioningEnabled $true
}

# Enable Blob soft delete
if (-not $BlobProperties.DeleteRetentionPolicy.Enabled -or $BlobProperties.DeleteRetentionPolicy.Days -ne 7) {
    Enable-AzStorageBlobDeleteRetentionPolicy -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -RetentionDays 7
}

# Enable Container soft delete
if (-not $BlobProperties.ContainerDeleteRetentionPolicy.Enabled -or $BlobProperties.ContainerDeleteRetentionPolicy.Days -ne 7) {
    Enable-AzStorageContainerDeleteRetentionPolicy -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -RetentionDays 7
}

# Configure Azure Files share soft delete.
if (-not $FileProperties.ShareDeleteRetentionPolicy.Enabled -or $FileProperties.ShareDeleteRetentionPolicy.Days -ne 7) {
    Update-AzStorageFileServiceProperty -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -EnableShareDeleteRetentionPolicy $true -ShareRetentionDays 7
}

# Verify Deployment
$BlobProperties = Get-AzStorageBlobServiceProperty -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName
$FileProperties = Get-AzStorageFileServiceProperty -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName

[PSCustomObject]@{
    BlobVersioning      = $BlobProperties.IsVersioningEnabled
    BlobSoftDelete      = $BlobProperties.DeleteRetentionPolicy.Enabled
    BlobRetentionDays   = $BlobProperties.DeleteRetentionPolicy.Days
    ContainerSoftDelete = $BlobProperties.ContainerDeleteRetentionPolicy.Enabled
    ContainerRetention  = $BlobProperties.ContainerDeleteRetentionPolicy.Days
    FilesSoftDelete     = $FileProperties.ShareDeleteRetentionPolicy.Enabled
    FilesRetentionDays  = $FileProperties.ShareDeleteRetentionPolicy.Days
} | Format-List
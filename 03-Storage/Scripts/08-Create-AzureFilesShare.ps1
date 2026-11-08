# Storage account configuration
$StorageAccountName = 'storagehm2k'
$ResourceGroupName = 'rg-storage'

# Azure Files configuration
$ShareName = 'labshare'

# Retrieve storage account key
$StorageAccountKey = (Get-AzStorageAccountKey -Name $StorageAccountName -ResourceGroupName $ResourceGroupName | Where-Object KeyName -eq 'key1').Value

# Create storage context
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

# Create Azure Files share
New-AzStorageShare -Name $ShareName -Context $Context

# Verify Deployment
Get-AzStorageShare -Name $ShareName -Context $Context
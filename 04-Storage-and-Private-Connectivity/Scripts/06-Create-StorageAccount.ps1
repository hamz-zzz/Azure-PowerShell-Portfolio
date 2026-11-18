# Storage account configuration
$StorageAccountName = 'storagehm2k'
$ResourceGroupName = 'rg-storage'
$Location = 'eastus2'

# Create storage account
New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -Kind StorageV2 -SkuName Standard_LRS

# Verify Deployment
$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
$StorageAccount | Format-Table StorageAccountName, Location, Kind, AccessTier
$StorageAccount.Sku | Format-Table Name, Tier
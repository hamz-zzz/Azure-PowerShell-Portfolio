# Resource configuration
$ResourceGroupName = 'rg-recovery-primary'
$Location = 'eastus2'
$StorageAccountName = 'storageasrcachehm2k'

# Create ASR Cache Storage Account
# Hint: New-AzStorageAccount
New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -Kind StorageV2 -SkuName Standard_LRS

# Verify Storage Account
$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
$StorageAccount | Format-Table StorageAccountName, Location, Kind, AccessTier
$StorageAccount.Sku | Format-Table Name, Tier
# Resource configuration
$ResourceGroupName = 'rg-storage'
$StorageAccountName = 'storagehm2k'

# Disable public network access
Set-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -PublicNetworkAccess Disabled

# Verify Deployment
Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName | Select-Object StorageAccountName, PublicNetworkAccess
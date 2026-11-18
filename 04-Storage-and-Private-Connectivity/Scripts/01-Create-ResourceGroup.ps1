# Resource configuration
$ResourceGroupName = 'rg-storage'
$Location = 'eastus2'

# Create resource group
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

# Verify Deployment
Get-AzResourceGroup -Name $ResourceGroupName -Location $Location
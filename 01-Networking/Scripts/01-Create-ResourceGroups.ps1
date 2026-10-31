# Resource group configuration
$ResourceGroupNames = ('rg-network-hub', 'rg-network-workload', 'rg-network-security')
$Location = 'eastus2'

# Create resource groups
foreach ($ResourceGroupName in $ResourceGroupNames) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

# Verify deployment
Get-AzResourceGroup | Where-Object -Property ResourceGroupName -in $ResourceGroupNames | Select-Object ResourceGroupName, Location, ProvisioningState | Format-Table
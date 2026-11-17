# Resource configuration
$WorkspaceName = 'law-network-hub'
$ResourceGroupName = 'rg-network-hub'
$Location = 'eastus2'

# Create Log Analytics workspace
$Workspace = New-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $ResourceGroupName -Location $Location

# Retrieve Log Analytics workspace
$Workspace = Get-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $ResourceGroupName

# Verify workspace deployment
$Workspace | Format-Table Name, Location, ProvisioningState
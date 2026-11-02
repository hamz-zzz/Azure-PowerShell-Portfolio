# Resource configuration
$WorkspaceName = 'law-network-hub'
$ResourceGroupName = 'rg-network-hub'
$Location = 'eastus2'

# Create Log Analytics workspace
# Hint: New-AzOperationalInsightsWorkspace
$Workspace = New-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $ResourceGroupName -Location $Location

# Retrieve Log Analytics workspace
# Hint: Get-AzOperationalInsightsWorkspace
$Workspace = Get-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $ResourceGroupName

# Verify workspace deployment
$Workspace | Format-Table Name, Location, ProvisioningState
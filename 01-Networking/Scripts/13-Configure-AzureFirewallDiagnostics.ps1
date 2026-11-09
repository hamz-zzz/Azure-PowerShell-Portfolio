# Firewall configuration
$FirewallName = 'azfw-hub'
$ResourceGroupName = 'rg-network-hub'

# Log Analytics configuration
$WorkspaceName = 'law-network-hub'
$DiagnosticSettingName = 'diag-azfw-hub'

# Log configuration
$Log = @(
    New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category 'AZFWNetworkRule'
    New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category 'AZFWApplicationRule'
)

# Retrieve Azure Firewall
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Retrieve Log Analytics workspace
$Workspace = Get-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $ResourceGroupName

# Configure diagnostic logs
New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $Firewall.Id -WorkspaceId $Workspace.ResourceId -Log $Log -LogAnalyticsDestinationType 'Dedicated'

# Verify diagnostic setting
$DiagnosticSetting = Get-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $Firewall.Id
$DiagnosticSetting.Log | Where-Object Enabled | Format-Table Category, Enabled
$DiagnosticSetting | Format-List Name, WorkspaceId, LogAnalyticsDestinationType
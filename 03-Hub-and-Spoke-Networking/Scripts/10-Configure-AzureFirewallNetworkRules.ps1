# Firewall configuration
$FirewallName = 'azfw-hub'
$ResourceGroupName = 'rg-network-hub'

# Network configuration
$SourceAddress = '10.1.0.0/24'
$DestinationAddress = '1.1.1.1'

# Network rule configuration
$RuleName = 'allow-dns'
$RuleCollectionName = 'rc-workload-network'

# Create network rule
$Rule = New-AzFirewallNetworkRule -Name $RuleName -SourceAddress $SourceAddress -DestinationAddress $DestinationAddress -Protocol UDP -DestinationPort 53

# Create network rule collection
$RuleCollection = New-AzFirewallNetworkRuleCollection -Name $RuleCollectionName -Priority 100 -ActionType Allow -Rule $Rule

# Retrieve Azure Firewall
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Add network rule collection to firewall
$Firewall.NetworkRuleCollections.Add($RuleCollection)

# Apply updated firewall configuration
Set-AzFirewall -AzureFirewall $Firewall

# Retrieve updated firewall configuration
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Verify network rule collection
$Firewall.NetworkRuleCollections | Format-Table Name, Priority
$Firewall.NetworkRuleCollections.Action
$Firewall.NetworkRuleCollections.Rules | Format-List
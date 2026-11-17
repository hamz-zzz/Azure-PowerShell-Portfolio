# Firewall configuration
$FirewallName = 'azfw-hub'
$ResourceGroupName = 'rg-network-hub'

# Application rule configuration
$RuleName = 'allow-https'
$RuleCollectionName = 'rc-workload-app'

# Network configuration
$SourceAddress = '10.1.0.0/24'
$TargetFQDN = 'google.com'
$Protocol = 'Https:443'

# Create application rule
$Rule = New-AzFirewallApplicationRule -Name $RuleName -SourceAddress $SourceAddress -TargetFqdn $TargetFQDN -Protocol $Protocol

# Create application rule collection
$RuleCollection = New-AzFirewallApplicationRuleCollection -Name $RuleCollectionName -Priority 200 -ActionType Allow -Rule $Rule

# Retrieve Azure Firewall
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Add application rule collection to firewall
$Firewall.ApplicationRuleCollections.Add($RuleCollection)

# Apply updated firewall configuration
Set-AzFirewall -AzureFirewall $Firewall

# Retrieve updated firewall configuration
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Verify application rule collection
$Firewall.ApplicationRuleCollections | Format-Table Name, Priority
$Firewall.ApplicationRuleCollections.Action
$Firewall.ApplicationRuleCollections.Rules | Format-List Name, SourceAddresses, TargetFqdns
$Firewall.ApplicationRuleCollections.Rules.Protocols
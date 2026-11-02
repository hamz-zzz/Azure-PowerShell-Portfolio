# Firewall configuration
$FirewallName = 'azfw-hub'
$ResourceGroupName = 'rg-network-hub'

# Application rule configuration
$RuleName = 'allow-https'
$RuleCollectionName = 'rc-workload-app'
$RuleCollectionPriority = 200
$RuleCollectionAction = 'Allow'

# Network configuration
$SourceAddress = '10.1.0.0/24'
$TargetFQDN = 'google.com'
$Protocol = 'Https:443'

# Create application rule
# Hint: New-AzFirewallApplicationRule
$Rule = New-AzFirewallApplicationRule -Name $RuleName -SourceAddress $SourceAddress -TargetFqdn $TargetFQDN -Protocol $Protocol

# Create application rule collection
# Hint: New-AzFirewallApplicationRuleCollection
$RuleCollection = New-AzFirewallApplicationRuleCollection -Name $RuleCollectionName -Priority $RuleCollectionPriority -ActionType $RuleCollectionAction -Rule $Rule

# Retrieve Azure Firewall
# Hint: Get-AzFirewall
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Add application rule collection to firewall
$Firewall.ApplicationRuleCollections.Add($RuleCollection)

# Apply updated firewall configuration
# Hint: Set-AzFirewall -AzureFirewall
Set-AzFirewall -AzureFirewall $Firewall

# Retrieve updated firewall configuration
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Verify application rule collection
$Firewall.ApplicationRuleCollections | Format-Table Name, Priority
$Firewall.ApplicationRuleCollections.Action
$Firewall.ApplicationRuleCollections.Rules | Format-List Name, SourceAddresses, TargetFqdns
$Firewall.ApplicationRuleCollections.Rules.Protocols
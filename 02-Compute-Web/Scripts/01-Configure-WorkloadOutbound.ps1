# Resource configuration
$ResourceGroupName = 'rg-network-hub'
$FirewallName = 'azfw-hub'

# Workload configuration
$SourceAddress = '10.1.0.0/24'

# Network rule collection configuration
$RuleCollectionName = 'rc-workload-network'

# Outbound rule configuration
$RuleName = 'allow-workload-internet'
$RuleDescription = 'Allow workload subnet outbound Internet access'
$DestinationAddresses = '*'
$Protocols = 'Any'
$DestinationPorts = '*'

# DNS rule configuration
$DNSRuleName = 'allow-dns'

# Retrieve existing Azure Firewall
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Retrieve existing network rule collection
$RuleCollection = $Firewall.GetNetworkRuleCollectionByName($RuleCollectionName)

# Create outbound network rule
$OutboundRule = New-AzFirewallNetworkRule -Name $RuleName -Description $RuleDescription -SourceAddress $SourceAddress -DestinationAddress $DestinationAddresses -Protocol $Protocols -DestinationPort $DestinationPorts

# Add rule to existing network rule collection
$RuleCollection.AddRule($OutboundRule)

# Remove DNS rule
$RuleCollection.RemoveRuleByName($DNSRuleName)

# Apply updated firewall configuration
Set-AzFirewall -AzureFirewall $Firewall

# Verify updated network rule collection
$UpdatedFirewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName
$UpdatedFirewall.GetNetworkRuleCollectionByName($RuleCollectionName).Rules
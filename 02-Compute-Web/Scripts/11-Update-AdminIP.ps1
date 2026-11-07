# Resource configuration
$ResourceGroupName = 'rg-compute-web'
$NSGName = 'nsg-web'

# Administrative access configuration
$AdminPublicIP = (Invoke-RestMethod https://api.ipify.org).Trim()
$AdminCIDR = "$AdminPublicIP/32"

# Retrieve network security group
$NSG = Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName

# Update RDP and SSH security rules
Set-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG -Name 'Allow-RDP-Admin' -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix $AdminCIDR -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange 3389 -Access Allow
Set-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG -Name 'Allow-SSH-Admin' -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix $AdminCIDR -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange 22 -Access Allow

# Update network security group
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSG

# Verify updated security rules
(Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName).SecurityRules |
    Format-Table Name, Priority, SourceAddressPrefix, DestinationPortRange
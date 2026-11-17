# DNS zone configuration
$DNSZoneName = 'systemsbyhamza.com'
$ResourceGroupName = 'rg-compute-web'

# Create DNS public zone
New-AzDnsZone -Name $DNSZoneName -ResourceGroupName $ResourceGroupName

# Verify DNS public zone
$DNSZone = Get-AzDnsZone -Name $DNSZoneName -ResourceGroupName $ResourceGroupName

# Retrieve authoritative nameservers
$DNSZone.NameServers
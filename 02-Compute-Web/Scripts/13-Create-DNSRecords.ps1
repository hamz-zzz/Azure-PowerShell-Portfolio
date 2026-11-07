# DNS zone configuration
$DNSZoneName = 'systemsbyhamza.com'

# Resource configuration
$ResourceGroupName = 'rg-compute-web'

# Load Balancer public IP configuration
$WindowsPublicIPName = 'pip-lb-windows'
$LinuxPublicIPName = 'pip-lb-linux'

# DNS record configuration
$WindowsRecordName = 'windows'
$LinuxRecordName = 'linux'

# Retrieve Load Balancer public IP addresses
$WindowsPublicIP = Get-AzPublicIpAddress -Name $WindowsPublicIPName -ResourceGroupName $ResourceGroupName
$LinuxPublicIP = Get-AzPublicIpAddress -Name $LinuxPublicIPName -ResourceGroupName $ResourceGroupName

# Create DNS A records
$WindowsRecord = New-AzDnsRecordConfig -Ipv4Address $WindowsPublicIP.IpAddress
New-AzDnsRecordSet -Name $WindowsRecordName -ZoneName $DNSZoneName -ResourceGroupName $ResourceGroupName -RecordType A -Ttl 300 -DnsRecords $WindowsRecord

$LinuxRecord = New-AzDnsRecordConfig -Ipv4Address $LinuxPublicIP.IpAddress
New-AzDnsRecordSet -Name $LinuxRecordName -ZoneName $DNSZoneName -ResourceGroupName $ResourceGroupName -RecordType A -Ttl 300 -DnsRecords $LinuxRecord

# Verify DNS records
Get-AzDnsRecordSet -ZoneName $DNSZoneName -ResourceGroupName $ResourceGroupName | Format-Table Name, RecordType, Records
# Private Connectivity Tests

# Windows to Ubuntu - SSH
Invoke-AzVMRunCommand -ResourceGroupName 'rg-network-workload' -VMName 'vm-windows01' -CommandId 'RunPowerShellScript' -ScriptString 'Test-NetConnection 10.1.0.5 -Port 22'

# Ubuntu to Windows - RDP
Invoke-AzVMRunCommand -ResourceGroupName 'rg-network-workload' -VMName 'vm-ubuntu01' -CommandId 'RunShellScript' -ScriptString 'nc -zv 10.1.0.4 3389'


# DNS Connectivity Tests

# Ubuntu - DNS
Invoke-AzVMRunCommand -ResourceGroupName 'rg-network-workload' -VMName 'vm-ubuntu01' -CommandId 'RunShellScript' -ScriptString 'nslookup google.com 1.1.1.1'

# Windows - DNS
Invoke-AzVMRunCommand -ResourceGroupName 'rg-network-workload' -VMName 'vm-windows01' -CommandId 'RunPowerShellScript' -ScriptString 'Resolve-DnsName google.com -Server 1.1.1.1'


# HTTPS Connectivity Tests

# Ubuntu - HTTPS
Invoke-AzVMRunCommand -ResourceGroupName 'rg-network-workload' -VMName 'vm-ubuntu01' -CommandId 'RunShellScript' -ScriptString 'curl -I --connect-timeout 10 https://google.com'

# Windows - HTTPS
Invoke-AzVMRunCommand -ResourceGroupName 'rg-network-workload' -VMName 'vm-windows01' -CommandId 'RunPowerShellScript' -ScriptString 'Test-NetConnection google.com -Port 443'
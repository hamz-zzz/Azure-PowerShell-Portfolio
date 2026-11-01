# VM configuration
$ResourceGroupName = 'rg-network-workload'
$WindowsVMName = 'vm-windows01'
$UbuntuVMName = 'vm-ubuntu01'

# Network configuration
$WindowsPrivateIP = '10.1.0.4'
$UbuntuPrivateIP = '10.1.0.5'

# Test Windows to Ubuntu (SSH - TCP 22)
Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -VMName $WindowsVMName -CommandId 'RunPowerShellScript' -ScriptString "Test-NetConnection $UbuntuPrivateIP -Port 22"

# Test Ubuntu to Windows (RDP - TCP 3389)
Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -VMName $UbuntuVMName -CommandId 'RunShellScript' -ScriptString "nc -zv $WindowsPrivateIP 3389"
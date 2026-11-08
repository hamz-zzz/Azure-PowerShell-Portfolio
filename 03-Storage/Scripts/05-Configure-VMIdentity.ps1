# Resource configuration
$ResourceGroupName = 'rg-storage'

# Virtual machine configuration
$VirtualMachineName = 'vm-windows'

# Retrieve virtual machine
$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName

# Enable system-assigned managed identity
Update-AzVM -VM $VirtualMachine -ResourceGroupName $ResourceGroupName -IdentityType SystemAssigned

# Verify Deployment
$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName
$VirtualMachine.Identity | Format-List PrincipalId, TenantId, Type
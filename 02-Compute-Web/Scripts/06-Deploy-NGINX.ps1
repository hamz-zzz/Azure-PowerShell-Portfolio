# VM configuration
$ResourceGroupName = 'rg-compute-web'
$VirtualMachineNames = 'vm-web-linux01', 'vm-web-linux02'
$Location = 'eastus2'

# Guest configuration
$ScriptPath = "$PSScriptRoot\..\Configs\Configure-NGINX.sh"

# Read and encode guest configuration
$ScriptContent = Get-Content -Path $ScriptPath -Raw -ErrorAction Stop
$EncodedScript = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($ScriptContent))

# Custom Script Extension configuration
$ExtensionName = 'NGINXConfiguration'
$Settings = @{
    script = $EncodedScript
}

# Deploy NGINX configuration to the Ubuntu VMs
for ($i = 0; $i -lt $VirtualMachineNames.Count; $i++) {
    Set-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VirtualMachineNames[$i] -Location $Location -Name $ExtensionName -Publisher 'Microsoft.Azure.Extensions' -ExtensionType 'CustomScript' -TypeHandlerVersion '2.1' -Settings $Settings
}

# Verify extension deployment
for ($i = 0; $i -lt $VirtualMachineNames.Count; $i++) {
    Get-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VirtualMachineNames[$i] | Where-Object Name -eq $ExtensionName | Select-Object VMName, Name, ExtensionType, ProvisioningState
}

# Verify extension deployment
for ($i = 0; $i -lt $VirtualMachineNames.Count; $i++) {
    Get-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VirtualMachineNames[$i] | Where-Object Name -eq $ExtensionName | Select-Object VMName, Name, ExtensionType, ProvisioningState
}
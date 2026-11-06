# VM configuration
$ResourceGroupName = 'rg-compute-web'
$VirtualMachineNames = 'vm-web-win01', 'vm-web-win02'
$Location = 'eastus2'

# Guest configuration
$ScriptPath = "$PSScriptRoot\..\Configs\Configure-IIS.ps1"

# Read and encode guest configuration
$ScriptContent = Get-Content -Path $ScriptPath -Raw -ErrorAction Stop
$EncodedScript = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ScriptContent))

# Custom Script Extension configuration
$ExtensionName = 'IISConfiguration'
$Settings = @{
    commandToExecute = "powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand $EncodedScript"
}

# Deploy IIS configuration to the Windows VMs
for ($i = 0; $i -lt $VirtualMachineNames.Count; $i++) {
    Set-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VirtualMachineNames[$i] -Location $Location -Name $ExtensionName -Publisher 'Microsoft.Compute' -ExtensionType 'CustomScriptExtension' -TypeHandlerVersion '1.10' -Settings $Settings

    # Verify extension deployment
    Get-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VirtualMachineNames[$i] | Where-Object Name -eq $ExtensionName | Select-Object VMName, Name, ExtensionType, ProvisioningState
}
# VM configuration
$ResourceGroupName = 'rg-network-workload'
$VMName = 'vm-windows01'
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

# Deploy IIS configuration to the Windows VM
Set-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Location $Location -Name $ExtensionName -Publisher 'Microsoft.Compute' -ExtensionType 'CustomScriptExtension' -TypeHandlerVersion '1.10' -Settings $Settings

# Verify extension deployment
Get-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName | Where-Object Name -eq $ExtensionName | Select-Object Name, ExtensionType,ProvisioningState
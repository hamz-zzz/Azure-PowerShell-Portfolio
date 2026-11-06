# VM configuration
$ResourceGroupName = 'rg-network-workload'
$VMName = 'vm-ubuntu01'
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

# Deploy NGINX configuration to the Ubuntu VM
Set-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Location $Location -Name $ExtensionName -Publisher 'Microsoft.Azure.Extensions' -ExtensionType 'CustomScript' -TypeHandlerVersion '2.1' -Settings $Settings

# Verify extension deployment
Get-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName | Where-Object Name -eq $ExtensionName | Select-Object Name, ExtensionType,ProvisioningState
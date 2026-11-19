# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$VMName = 'vm-primary-test'
$PublicIPName = 'pip-primary-test'
$Location = 'Central US'

# Retrieve Recovered VM
$RecoveryVM = Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName

# Retrieve Network Interface
$NICId = $RecoveryVM.NetworkProfile.NetworkInterfaces[0].Id
$NIC = Get-AzNetworkInterface -ResourceId $NICId

# Create Public IP
$PublicIP = New-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Static

# Associate Public IP with Network Interface
$NIC.IpConfigurations[0].PublicIpAddress =  $PublicIP
Set-AzNetworkInterface -NetworkInterface $NIC | Out-Null

# Update IIS Webpage
$Script = "& 'C:\Guest-Configs\03-Generate-IISWebpage.ps1'"
Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -VMName $VMName -CommandId 'RunPowerShellScript' -ScriptString $Script

# Verify Recovery VM Access Configuration
$NIC = Get-AzNetworkInterface -ResourceId $NICId
$NIC | Select-Object Name, @{Name = 'Public IP'; Expression = {Split-Path $_.IpConfigurations[0].PublicIpAddress.Id -Leaf}}
Get-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName | Format-List Name, IpAddress

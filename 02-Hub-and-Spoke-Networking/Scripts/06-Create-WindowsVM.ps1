# Virtual machine configuration
$VMName = 'vm-windows01'
$VMSize = 'Standard_B2s_v2'
$Location = 'eastus2'

# Resource configuration
$ResourceGroupName = 'rg-network-workload'
$VirtualNetworkName = 'vnet-workload'
$SubnetName = 'snet-workload'

# Network configuration
$NICName = 'nic-windows01'
$PrivateIPAddress = '10.1.0.4'

# Oprating system configuration
$PublisherName = 'MicrosoftWindowsServer'
$Offer = 'WindowsServer'
$SKU = '2022-datacenter-azure-edition'
$Version = 'latest'

# Disk configuration
$OSDiskName = 'osdisk-windows01'
$OSDiskType = 'StandardSSD_LRS'

# Retrieve virtual network configuration
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Retrieve subnet configuration
$Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VirtualNetwork -Name $SubnetName

# Create network interface
$NetworkInterface = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $Subnet.Id -PrivateIpAddress $PrivateIPAddress

# Create VM credentials
$Credential = Get-Credential -Message 'Enter the local administrator credentials for the Azure VM'

# Configure virtual machine
$VMConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize

# Enable Boot Diagnostics using Microsoft-managed storage
Set-AzVMBootDiagnostic -VM $VMConfig -Enable

# Configure operating system
Set-AzVMOperatingSystem -VM $VMConfig -ComputerName $VMName -Credential $Credential -Windows

# Configure source image
Set-AzVMSourceImage -VM $VMConfig -PublisherName $PublisherName -Offer $Offer -Skus $SKU -Version $Version

# Configure OS disk
Set-AzVMOSDisk -VM $VMConfig -Name $OSDiskName -CreateOption FromImage -StorageAccountType $OSDiskType

# Attach network interface
$VirtualMachine = Add-AzVMNetworkInterface -VM $VMConfig -Id $NetworkInterface.Id

# Deploy virtual machine
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine

# Verify deployment
$VirtualMachine = Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName
$VirtualMachine | Format-Table Name, Location, ProvisioningState

# Verify network configuration
$NetworkInterface = Get-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName
$NetworkInterface.IpConfigurations | Format-Table Name, PrivateIpAddress, PrivateIpAllocationMethod
# Resource configuration
$ResourceGroupName = 'rg-storage'
$Location = 'eastus2'

# Virtual network configuration
$VirtualNetworkName = 'vnet-storage'
$SubnetName = 'snet-storage'

# Public IP configuration
$PublicIPName = 'pip-windows'

# Network interface configuration
$NetworkInterfaceName = 'nic-windows'

# Virtual machine configuration
$VMName = 'vm-windows'
$VMSize = 'Standard_B2s_v2'

# Operating system configuration
$Publisher = 'MicrosoftWindowsServer'
$Offer = 'WindowsServer'
$SKU = '2022-datacenter'
$Version = 'latest'
$OSDiskName = 'disk-windows'

# Retrieve virtual network
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Retrieve subnet
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq $SubnetName

# Create VM credentials
$Credential = Get-Credential -Message 'Enter the local administrator credentials for the Azure VM'

# Create public IP address
$PublicIP = New-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Static

# Create network interface
$NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -PrivateIpAddress '10.0.0.4' -Subnet $Subnet -PublicIpAddress $PublicIP

# Create virtual machine configuration
$VMConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize

# Configure operating system
Set-AzVMOperatingSystem -VM $VMConfig -ComputerName $VMName -Credential $Credential -Windows

# Configure source image
Set-AzVMSourceImage -VM $VMConfig -PublisherName $Publisher -Offer $Offer -Skus $SKU -Version $Version

# Configure OS disk
Set-AzVMOSDisk -VM $VMConfig -Name $OSDiskName -StorageAccountType StandardSSD_LRS -CreateOption FromImage

# Enable managed boot diagnostics
Set-AzVMBootDiagnostic -VM $VMConfig -Enable

# Attach network interface
Add-AzVMNetworkInterface -VM $VMConfig -Id $NetworkInterface.Id

# Deploy virtual machine
New-AzVM -VM $VMConfig -ResourceGroupName $ResourceGroupName -Location $Location

# Verify Deployment
$VirtualMachine = Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName
$VirtualMachine | Format-Table Name, Location, ProvisioningState
$PublicIP = Get-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName
$PublicIP | Format-Table Name, IpAddress
$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName
$NetworkInterface.IpConfigurations | Select-Object PrivateIpAddress, PrivateIpAllocationMethod
$NetworkInterface | Select-Object Name, @{N='Virtual Machine'; E={Split-Path $_.VirtualMachine.Id -Leaf}}
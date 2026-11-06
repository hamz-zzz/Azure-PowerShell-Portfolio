# Virtual machine configuration
$VirtualMachineNames = 'vm-web-linux01', 'vm-web-linux02'
$VirtualMachineSize = 'Standard_B2ts_v2'
$Location = 'eastus2'

# Resource configuration
$ResourceGroupName = 'rg-compute-web'
$VirtualNetworkName = 'vnet-compute-web'
$SubnetName = 'snet-web'

# Network configuration
$NetworkInterfaceNames = 'nic-web-linux01', 'nic-web-linux02'
$PrivateIPAddresses = '10.0.0.6', '10.0.0.7'

# Operating system configuration
$PublisherName = 'Canonical'
$Offer = 'ubuntu-24_04-lts'
$SKU = 'server'
$Version = 'latest'

# Disk configuration
$OSDiskNames = 'osdisk-web-linux01', 'osdisk-web-linux02'
$OSDiskType = 'StandardSSD_LRS'

# Retrieve virtual network configuration
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Retrieve subnet configuration
$Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VirtualNetwork -Name $SubnetName

# Create VM credentials
$Credential = Get-Credential -Message 'Enter the local administrator credentials for the Azure VM'

# Deploy virtual machines
for ($i = 0; $i -lt $VirtualMachineNames.Count; $i++) {

    # Create network interface
    $NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceNames[$i] -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $Subnet.Id -PrivateIpAddress $PrivateIPAddresses[$i]

    # Configure virtual machine
    $VMConfig = New-AzVMConfig -VMName $VirtualMachineNames[$i] -VMSize $VirtualMachineSize

    # Enable Boot Diagnostics using Microsoft-managed storage
    Set-AzVMBootDiagnostic -VM $VMConfig -Enable

    # Configure operating system
    Set-AzVMOperatingSystem -VM $VMConfig -ComputerName $VirtualMachineNames[$i] -Credential $Credential -Linux

    # Configure source image
    Set-AzVMSourceImage -VM $VMConfig -PublisherName $PublisherName -Offer $Offer -Skus $SKU -Version $Version

    # Configure OS disk
    Set-AzVMOSDisk -VM $VMConfig -Name $OSDiskNames[$i] -CreateOption FromImage -StorageAccountType $OSDiskType

    # Attach network interface
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VMConfig -Id $NetworkInterface.Id

    # Deploy virtual machine
    New-AzVM  -VM $VirtualMachine -ResourceGroupName $ResourceGroupName -Location $Location
}

# Verify VM configuration
$VirtualMachines = Get-AzVM -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -in $VirtualMachineNames }
$VirtualMachines | Format-Table Name, Location, ProvisioningState

# Verify network configuration
$NetworkInterfaces = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -in $NetworkInterfaceNames }
$NetworkInterfaces | ForEach-Object {$_.IpConfigurations | Select-Object Name, PrivateIpAddress, PrivateIpAllocationMethod}
$NetworkInterfaces | Select-Object Name, @{N='Virtual Machine'; E={Split-Path $_.VirtualMachine.Id -Leaf}}
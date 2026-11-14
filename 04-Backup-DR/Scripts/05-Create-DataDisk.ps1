# Resource configuration
$ResourceGroupName = 'rg-recovery-primary'
$Location = 'eastus2'
$VMName = 'vm-primary'
$DiskName = 'disk-data'

# Create Managed Disk
$DiskConfig = New-AzDiskConfig -SkuName StandardSSD_LRS -DiskSizeGB 32 -CreateOption Empty -Location $Location
$Disk =  New-AzDisk -DiskName $DiskName -ResourceGroupName $ResourceGroupName -Disk $DiskConfig

# Attach Data Disk to Virtual Machine
$VM = Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName
Add-AzVMDataDisk -VM $VM -Name $DiskName -ManagedDiskId $Disk.Id -Lun 0 -CreateOption Attach
Update-AzVM -VM $VM -ResourceGroupName $ResourceGroupName

# Verify Deployment
$Disk = Get-AzDisk -DiskName $DiskName -ResourceGroupName $ResourceGroupName
$Disk | Select-Object Name, DiskSizeGB, @{Name = 'SKU'; Expression = {$_.Sku.Name}}, Location, ProvisioningState | Format-Table
$VM = Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName
$VM.StorageProfile.DataDisks | Select-Object Name, DiskSizeGB, @{Name = 'SKU'; Expression = {$_.ManagedDisk.StorageAccountType}}, Lun, CreateOption | Format-Table
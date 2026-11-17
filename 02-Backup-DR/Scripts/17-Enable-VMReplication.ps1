# Resource configuration
$ResourceGroupName = 'rg-recovery-primary'
$VMName = 'vm-primary'
$StorageAccountName = 'storageasrcachehm2k'

$RecoveryResourceGroupName = 'rg-recovery-secondary'
$VaultName = 'rsv-asr-secondary'
$PrimaryFabricName = 'fabric-primary'
$MappingName = 'mapping-primary-secondary'
$RecoveryVNetName = 'vnet-secondary'
$RecoverySubnetName = 'snet-secondary'

# Retrieve Recovery Resource Group
$RecoveryResourceGroup = Get-AzResourceGroup -Name $RecoveryResourceGroupName

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $RecoveryResourceGroupName

# Import ASR Vault Settings
$VaultSettings = Get-AzRecoveryServicesVaultSettingsFile -Vault $Vault -SiteRecovery
Import-AzRecoveryServicesAsrVaultSettingsFile -Path $VaultSettings.FilePath

# Set ASR Vault Context
Set-AzRecoveryServicesAsrVaultContext -Vault $Vault

# Retrieve ASR Primary Fabric
$PrimaryFabric = Get-AzRecoveryServicesAsrFabric -Name $PrimaryFabricName

# Retrieve ASR Protection Primary Container
$PrimaryContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $PrimaryFabric

# Retrieve Protection Container Mapping
$Mapping = Get-AzRecoveryServicesAsrProtectionContainerMapping -Name $MappingName -ProtectionContainer $PrimaryContainer

# Retrieve Source VM and Cache Storage Account
$VirtualMachine = Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName
$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName

# Retrieve Recovery VNet
$RecoveryVNet = Get-AzVirtualNetwork -Name $RecoveryVNetName -ResourceGroupName $RecoveryResourceGroupName

# Configure and Enable VM Replication
$Job = New-AzRecoveryServicesAsrReplicationProtectedItem -AzureToAzure -AzureVmId $VirtualMachine.Id -Name $VirtualMachine.Name -ProtectionContainerMapping $Mapping -LogStorageAccountId $StorageAccount.Id -RecoveryResourceGroupId $RecoveryResourceGroup.ResourceId -RecoveryAzureNetworkId $RecoveryVNet.Id -RecoveryAzureSubnetName $RecoverySubnetName

# Monitor Replication Enablement Job
while ($Job.State -in @('NotStarted', 'InProgress')) {
    Write-Host 'Replication Enablement job is still running. Checking again in 30 seconds...' -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    $Job = Get-AzRecoveryServicesAsrJob -Job $Job
}

# Display Final Job Status
$Job | Format-Table TargetObjectName, JobType, State

# Verify Replication
$ReplicationItem = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $PrimaryContainer
$ReplicationItem | Format-List Name, ProtectionState, ProtectionStateDescription, ReplicationHealth, ReplicationHealthErrors, RecoveryFabricFriendlyName, RecoveryProtectionContainerFriendlyName
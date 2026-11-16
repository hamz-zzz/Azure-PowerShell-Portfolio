# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$VaultName = 'rsv-asr-secondary'
$PrimaryFabricName = 'fabric-primary'
$RecoveryVNetName = 'vnet-secondary'
$PrimaryVMName = 'vm-primary'

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName

# Import ASR Vault Settings
$VaultSettings = Get-AzRecoveryServicesVaultSettingsFile -Vault $Vault -SiteRecovery
Import-AzRecoveryServicesAsrVaultSettingsFile -Path $VaultSettings.FilePath

# Set ASR Vault Context
Set-AzRecoveryServicesAsrVaultContext -Vault $Vault

# Retrieve ASR Primary Fabric and Protection Container
$PrimaryFabric = Get-AzRecoveryServicesAsrFabric -Name $PrimaryFabricName
$PrimaryContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $PrimaryFabric

# Retrieve Replication Protected Item
$ReplicationItem = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $PrimaryContainer | Where-Object Name -eq $PrimaryVMName

# Retrieve Latest Recovery Point
$LatestRecoveryPoint = Get-AzRecoveryServicesAsrRecoveryPoint -ReplicationProtectedItem $ReplicationItem | Sort-Object RecoveryPointTime -Descending | Select-Object -First 1

# Retrieve Recovery Virtual Network
$RecoveryVNet = Get-AzVirtualNetwork -Name $RecoveryVNetName -ResourceGroupName $ResourceGroupName

# Start Test Failover
$Job = Start-AzRecoveryServicesAsrTestFailoverJob -ReplicationProtectedItem $ReplicationItem -Direction PrimaryToRecovery -AzureVMNetworkId $RecoveryVNet.Id -RecoveryPoint $LatestRecoveryPoint

# Monitor Test Failover Job
while ($Job.State -in @('NotStarted', 'InProgress')) {
    Write-Host 'Test Failover job is still running. Checking again in 30 seconds...' -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    $Job = Get-AzRecoveryServicesAsrJob -Job $Job
}

# Display Final Job Status
$Job | Format-Table TargetObjectName, JobType, State

# Stop execution if the test failover job fails
if ($Job.State -ne 'Succeeded') {
    Write-Warning "Test Failover did not succeed. Final state: $($Job.State)"
    return
}

# Verify Test Failover
$RecoveredVM = Get-AzVM -ResourceGroupName $ResourceGroupName -Status
$RecoveredVM | Select-Object Name, Location, PowerState
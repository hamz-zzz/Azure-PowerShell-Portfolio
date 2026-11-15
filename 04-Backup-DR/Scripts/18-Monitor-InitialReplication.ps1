# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$VaultName = 'rsv-asr-secondary'
$PrimaryFabricName = 'fabric-primary'

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName

# Import ASR Vault Settings
$VaultSettings = Get-AzRecoveryServicesVaultSettingsFile -Vault $Vault -SiteRecovery
Import-AzRecoveryServicesAsrVaultSettingsFile -Path $VaultSettings.FilePath

# Set ASR Vault Context
Set-AzRecoveryServicesAsrVaultContext -Vault $Vault

# Retrieve ASR Primary Fabric
$PrimaryFabric = Get-AzRecoveryServicesAsrFabric -Name $PrimaryFabricName

# Retrieve ASR Protection Container
$PrimaryContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $PrimaryFabric

# Monitor Initial Replication Progress
do {
    $ReplicationItem = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $PrimaryContainer
    
    Write-Host "Initial Replication: $($ReplicationItem.ProviderSpecificDetails.MonitoringPercentageCompletion)% complete" -ForegroundColor Yellow

    if ($ReplicationItem.ProviderSpecificDetails.MonitoringPercentageCompletion -lt 100) {
        Start-Sleep -Seconds 30
    }

} while ($ReplicationItem.ProviderSpecificDetails.MonitoringPercentageCompletion -lt 100)

Write-Host 'Initial replication completed.' -ForegroundColor Green

# Verify Replication
$ReplicationItem | Format-List Name, ProtectionState, ProtectionStateDescription, ReplicationHealth
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
    Write-Host "Protection State: $($ReplicationItem.ProtectionStateDescription)"
    if (
        $ReplicationItem.ProtectionState -ne 'Protected'
    ) {
        Start-Sleep -Seconds 30
    }
} while (
    $ReplicationItem.ProtectionState -ne 'Protected'
)

Write-Host 'Initial replication completed and protection is established.' -ForegroundColor Green

# Verify Replication
$ReplicationItem | Format-List Name, ProtectionState, ReplicationHealth
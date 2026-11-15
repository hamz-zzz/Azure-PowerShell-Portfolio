# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$VaultName = 'rsv-asr-secondary'
$PrimaryFabricName = 'fabric-primary'
$SecondaryFabricName = 'fabric-secondary'
$PrimaryContainerName = 'container-primary'
$SecondaryContainerName = 'container-secondary'
$PolicyName = 'policy-asr'
$MappingName = 'mapping-primary-secondary'


# Retrieve Recovery Services Vault
# Hint: Get-AzRecoveryServicesVault
$Vault =


# Import ASR Vault Settings
# Hint: Get-AzRecoveryServicesVaultSettingsFile, Import-AzRecoveryServicesAsrVaultSettingsFile


# Set ASR Vault Context
# Hint: Set-AzRecoveryServicesAsrVaultContext


# Retrieve ASR Fabrics
# Hint: Get-AzRecoveryServicesAsrFabric
$PrimaryFabric =
$SecondaryFabric =


# Retrieve ASR Protection Containers
# Hint: Get-AzRecoveryServicesAsrProtectionContainer
$PrimaryContainer =
$SecondaryContainer =


# Retrieve ASR Replication Policy
# Hint: Get-AzRecoveryServicesAsrPolicy
$Policy =


# Create ASR Protection Container Mapping
# Hint: New-AzRecoveryServicesAsrProtectionContainerMapping


# Verify Protection Container Mapping
# Hint: Get-AzRecoveryServicesAsrProtectionContainerMapping
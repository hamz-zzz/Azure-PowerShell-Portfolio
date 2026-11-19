# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$VaultName = 'rsv-asr-secondary'
$PolicyName = 'policy-asr'

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName

# Import ASR Vault Settings
$VaultSettings = Get-AzRecoveryServicesVaultSettingsFile -Vault $Vault -SiteRecovery
Import-AzRecoveryServicesAsrVaultSettingsFile -Path $VaultSettings.FilePath

# Set ASR Vault Context
Set-AzRecoveryServicesAsrVaultContext -Vault $Vault

# Create ASR Replication Policy
New-AzRecoveryServicesAsrPolicy -AzureToAzure -Name $PolicyName -RecoveryPointRetentionInHours 24

# Verify Replication Policy
Get-AzRecoveryServicesAsrPolicy -Name $PolicyName
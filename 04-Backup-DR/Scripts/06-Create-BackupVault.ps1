# Resource configuration
$ResourceGroupName = 'rg-recovery-primary'
$Location = 'eastus2'
$VaultName = 'rsv-backup-primary'

# Create Recovery Services Vault
$Vault = New-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName -Location $Location

# Configure Backup Storage Redundancy
Set-AzRecoveryServicesBackupProperty -Vault $Vault -BackupStorageRedundancy LocallyRedundant

# Verify Deployment
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName
$Vault | Format-Table Name, ResourceGroupName, Location
$Vault.Properties.RedundancySettings
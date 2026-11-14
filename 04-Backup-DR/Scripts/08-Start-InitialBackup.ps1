# Resource configuration
$ResourceGroupName = 'rg-recovery-primary'
$VaultName = 'rsv-backup-primary'
$VMName = 'vm-primary'


# Retrieve Recovery Services Vault
# Hint: Get-AzRecoveryServicesVault


# Set Recovery Services Vault Context
# Hint: Set-AzRecoveryServicesVaultContext


# Retrieve Protected VM Backup Item
# Hint: Get-AzRecoveryServicesBackupItem
# WorkloadType and BackupManagementType: AzureVM


# Check Existing Backup Status
# Check whether a backup job is already running or a recovery point exists


# Start On-Demand Backup
# Hint: Backup-AzRecoveryServicesBackupItem
# Use the appropriate retention parameter


# Monitor Backup Job
# Hint: Get-AzRecoveryServicesBackupJob
# Monitor until the job completes


# Verify Initial Backup
# Confirm successful job status and a valid recovery point
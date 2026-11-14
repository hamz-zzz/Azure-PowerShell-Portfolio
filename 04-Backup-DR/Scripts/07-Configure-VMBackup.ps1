
# Resource configuration
$ResourceGroupName = 'rg-recovery-primary'
$Location = 'eastus2'
$VaultName = 'rsv-backup-primary'
$VMName = 'vm-primary'
$PolicyName = 'policy-vm-daily'


# Retrieve Recovery Services Vault
# Hint: Get-AzRecoveryServicesVault


# Set Recovery Services Vault Context
# Hint: Set-AzRecoveryServicesVaultContext


# Retrieve Default VM Backup Schedule and Retention Policy Objects
# Hint: Get-AzRecoveryServicesBackupSchedulePolicyObject
# Hint: Get-AzRecoveryServicesBackupRetentionPolicyObject


# Configure Backup Schedule
# Daily backup frequency
# Set the backup time


# Configure Retention Policy
# Retain daily recovery points for 30 days


# Create Backup Policy
# Hint: New-AzRecoveryServicesBackupProtectionPolicy


# Enable VM Backup Protection
# Hint: Enable-AzRecoveryServicesBackupProtection


# Verify Backup Policy
# Hint: Get-AzRecoveryServicesBackupProtectionPolicy


# Verify VM Backup Protection
# Hint: Get-AzRecoveryServicesBackupItem

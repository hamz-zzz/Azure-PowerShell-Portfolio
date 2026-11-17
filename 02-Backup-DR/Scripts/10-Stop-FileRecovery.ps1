# Resource configuration
$ResourceGroupName = 'rg-recovery-primary'
$VaultName = 'rsv-backup-primary'
$VMName = 'vm-primary'

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName

# Set Recovery Services Vault Context
Set-AzRecoveryServicesVaultContext -Vault $Vault

# Retrieve Protected VM Backup Item
$BackupItem = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM -FriendlyName $VMName

# Retrieve Recovery Points
$RecoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $BackupItem -VaultId $Vault.Id

# Select Latest Recovery Point
$LatestRecoveryPoint = $RecoveryPoints | Sort-Object RecoveryPointTime -Descending | Select-Object -First 1

# Dismount File Recovery
Disable-AzRecoveryServicesBackupRPMountScript -RecoveryPoint $LatestRecoveryPoint -VaultId $Vault.Id
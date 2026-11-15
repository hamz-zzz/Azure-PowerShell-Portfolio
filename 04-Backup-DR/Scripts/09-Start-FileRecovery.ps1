# Resource configuration
$ResourceGroupName = 'rg-recovery-primary'
$VaultName = 'rsv-backup-primary'
$VMName = 'vm-primary'
$DownloadPath = "$env:USERPROFILE\AzureFileRecovery"
$PasswordFile = "$DownloadPath\RecoveryPassword.txt"

# Create Download Directory if it doesn't exist
if (-not (Test-Path -Path $DownloadPath)) {
    New-Item -Path $DownloadPath -ItemType Directory
}

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

# Download File Recovery Mount Script and save Recovery Password
$MountScript = Get-AzRecoveryServicesBackupRPMountScript -RecoveryPoint $LatestRecoveryPoint -Path $DownloadPath -VaultId $Vault.Id
$MountScript.Password | Set-Content -Path $PasswordFile

# Verify Recovery Point and Mount Script    
$LatestRecoveryPoint | Format-List RecoveryPointTime, RecoveryPointType
Get-ChildItem -Path $DownloadPath
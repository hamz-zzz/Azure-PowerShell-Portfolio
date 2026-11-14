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

# Check Existing Backup Status
$Jobs = Get-AzRecoveryServicesBackupJob -Status InProgress -Operation Backup -BackupManagementType AzureVM -VaultId $Vault.Id | Where-Object WorkloadName -eq $VMName
$RecoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $BackupItem -VaultId $Vault.Id

# Start On-Demand Backup
$Job = $null
if ($Jobs) {
    Write-Host 'Backup already running. Monitoring existing job.'
    $Job = $Jobs | Select-Object -First 1
}
elseif ($RecoveryPoints) {
    Write-Host 'Recovery point already exists. Skipping backup.'
}
else {
    Write-Host 'No backup job or recovery point found. Starting backup.'
    $Job = Backup-AzRecoveryServicesBackupItem -Item $BackupItem -ExpiryDateTimeUTC (Get-Date).ToUniversalTime().AddDays(30)
}

# Monitor Backup Job
if ($Job) {
    while ($Job.Status -eq 'InProgress') {
        Write-Host 'Backup is running...'
        Start-Sleep -Seconds 30
        $Job = Get-AzRecoveryServicesBackupJob -Job $Job -VaultId $Vault.Id
    }
    $Job | Format-List WorkloadName, Operation, Status, StartTime, EndTime
}

# Verify Initial Backup
if ($Job) {
    $Job | Format-Table WorkloadName, Status, StartTime, EndTime
}
$RecoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $BackupItem -VaultId $Vault.Id
$RecoveryPoints | Select-Object -First 1 RecoveryPointTime, RecoveryPointType | Format-Table
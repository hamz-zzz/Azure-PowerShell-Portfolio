
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
    Write-Host 'Backup already running. Monitoring existing job.' -ForegroundColor Yellow
    $Job = $Jobs | Select-Object -First 1
}
elseif ($RecoveryPoints) {
    Write-Host 'Recovery point already exists. Skipping backup.' -ForegroundColor Yellow
}
else {
    Write-Host 'No backup job or recovery point found. Starting backup.' -ForegroundColor Yellow
    $Job = Backup-AzRecoveryServicesBackupItem -Item $BackupItem -ExpiryDateTimeUTC (Get-Date).ToUniversalTime().AddDays(30)
}

# Monitor Backup Job
if ($Job) {
    while ($Job.Status -eq 'InProgress') {
        Write-Host 'Backup is running. Checking again in 30 seconds...' -ForegroundColor Yellow

        # Retrieve Backup Job Details
        $JobDetails = Get-AzRecoveryServicesBackupJobDetail -JobId $Job.JobId -VaultId $Vault.Id

        # Display Subtask Status
        $JobDetails.SubTasks | Format-Table Name, Status, Duration

        Start-Sleep -Seconds 30

        # Refresh Backup Job Status
        $Job = Get-AzRecoveryServicesBackupJob -Job $Job -VaultId $Vault.Id
    }

    # Retrieve Final Job Details
    $JobDetails = Get-AzRecoveryServicesBackupJobDetail -JobId $Job.JobId -VaultId $Vault.Id
    $JobDetails.SubTasks | Format-Table Name, Status, Duration

    # Display Final Backup Status
    if ($Job.Status -eq 'Completed') {
        Write-Host 'Backup completed successfully.' -ForegroundColor Green
    }
    else {
        Write-Host "Backup finished with status: $($Job.Status)" -ForegroundColor Red
    }

    $Job | Format-List WorkloadName, Operation, Status, StartTime, EndTime
}

# Verify Initial Backup
$RecoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $BackupItem -VaultId $Vault.Id
$RecoveryPoints | Sort-Object RecoveryPointTime -Descending | Select-Object -First 1 RecoveryPointTime, RecoveryPointType
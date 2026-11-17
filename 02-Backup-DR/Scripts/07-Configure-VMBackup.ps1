# Resource configuration
$ResourceGroupName = 'rg-recovery-primary'
$VaultName = 'rsv-backup-primary'
$VMName = 'vm-primary'
$PolicyName = 'policy-vm-daily'

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName

# Set Recovery Services Vault Context
Set-AzRecoveryServicesVaultContext -Vault $Vault

# Retrieve Default VM Backup Schedule and Retention Policy Objects
$SchedulePolicy = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType AzureVM -PolicySubType Standard
$RetentionPolicy = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType AzureVM

# Configure Backup Schedule
$SchedulePolicy.ScheduleRunFrequency = 'Daily'
$SchedulePolicy.ScheduleRunTimes.Clear()
$BackupTime = (Get-Date -Hour 23 -Minute 0 -Second 0 -Millisecond 0).ToUniversalTime()
$SchedulePolicy.ScheduleRunTimes.Add($BackupTime)

# Configure Retention Policy
$RetentionPolicy.DailySchedule.DurationCountInDays = 30

# Create Backup Policy
$Policy = New-AzRecoveryServicesBackupProtectionPolicy -Name $PolicyName -WorkloadType AzureVM -SchedulePolicy $SchedulePolicy -RetentionPolicy $RetentionPolicy

# Enable VM Backup Protection
Enable-AzRecoveryServicesBackupProtection -Policy $Policy -Name $VMName -ResourceGroupName $ResourceGroupName

# Verify Backup Policy
$Policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name $PolicyName
$Policy | Format-List Name, WorkloadType, BackupManagementType, PolicySubType
$Policy.SchedulePolicy | Format-Table ScheduleRunFrequency, ScheduleRunTimes, ScheduleRunTimeZone
$Policy.RetentionPolicy.DailySchedule

# Verify VM Backup Protection
$BackupItem = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM -FriendlyName $VMName
$BackupItem | Format-List VirtualMachineId, ProtectionStatus, ProtectionState, ProtectionPolicyName, LastBackupStatus, LatestRecoveryPoint
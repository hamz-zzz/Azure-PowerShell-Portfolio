# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$VaultName = 'rsv-asr-secondary'
$PrimaryFabricName = 'fabric-primary'
$PrimaryVMName = 'vm-primary'
$PublicIPName = 'pip-primary-test'
$RecoveryVMName = 'vm-primary-test'
$RecoveryNICName = 'nic-primary-test'

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName

# Set ASR Vault Context
Set-AzRecoveryServicesAsrVaultContext -Vault $Vault

# Retrieve ASR Primary Fabric and Protection Container
$PrimaryFabric = Get-AzRecoveryServicesAsrFabric -Name $PrimaryFabricName
$PrimaryContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $PrimaryFabric

# Retrieve Replication Protected Item
$ReplicationItem = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $PrimaryContainer | Where-Object Name -eq $PrimaryVMName

# Start Test Failover Cleanup
$Job = Start-AzRecoveryServicesAsrTestFailoverCleanupJob -ReplicationProtectedItem $ReplicationItem

# Monitor Cleanup Job
while ($Job.State -in @('NotStarted', 'InProgress')) {
    Write-Host 'Test Failover Cleanup job is still running. Checking again in 30 seconds...' -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    $Job = Get-AzRecoveryServicesAsrJob -Job $Job
}

# Display Final Job Status
$Job | Format-Table TargetObjectName, JobType, State

# Stop execution if the test failover job fails
if ($Job.State -ne 'Succeeded') {
    Write-Warning "Test Failover Cleanup failed. Final state: $($Job.State)"
    return
}

# Verify Recovery VM and NIC Removal
$RecoveryVM = Get-AzVM -Name $RecoveryVMName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$RecoveryNIC = Get-AzNetworkInterface -Name $RecoveryNICName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if ($RecoveryVM -or $RecoveryNIC) {
    Write-Warning 'Recovery VM or NIC still exists. Investigate ASR cleanup before proceeding.'
    return
}
else {
    Remove-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -Force
}

# Verify Cleanup
Get-AzVM -ResourceGroupName $ResourceGroupName
Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName
Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName
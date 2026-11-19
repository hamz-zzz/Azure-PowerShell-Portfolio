# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$VaultName = 'rsv-asr-secondary'
$Fabrics = @(
    @{
        Name     = 'fabric-primary'
        Location = 'eastus2'
    },
    @{
        Name     = 'fabric-secondary'
        Location = 'centralus'
    }
)

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName

# Set ASR Vault Context
Set-AzRecoveryServicesAsrVaultContext -Vault $Vault

# Create ASR Fabrics
$FabricJobs = @()
foreach ($Fabric in $Fabrics) {
    $FabricJobs += New-AzRecoveryServicesAsrFabric -Azure -Name $Fabric.Name -Location $Fabric.Location
}

# Monitor Fabric Creation Jobs
do {
    $RunningJobs = @()

    foreach ($FabricJob in $FabricJobs) {
        $Job = Get-AzRecoveryServicesAsrJob -Job $FabricJob

        if ($Job.State -in @('NotStarted', 'InProgress')) {
            $RunningJobs += $Job
        }
    }

    if ($RunningJobs) {
        Write-Host 'Fabric creation jobs are still running. Checking again in 30 seconds...' -ForegroundColor Yellow
        Start-Sleep -Seconds 30
    }

} while ($RunningJobs)

# Display Final Job Results
foreach ($FabricJob in $FabricJobs) {
    Get-AzRecoveryServicesAsrJob -Job $FabricJob | Format-Table TargetObjectName, JobType, State
}

# Verify Fabric Deployment
foreach ($Fabric in $Fabrics) {
    Get-AzRecoveryServicesAsrFabric -Name $Fabric.Name | Format-Table Name, FriendlyName
}
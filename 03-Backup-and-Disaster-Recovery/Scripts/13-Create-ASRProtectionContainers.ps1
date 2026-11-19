# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$VaultName = 'rsv-asr-secondary'
$Containers = @(
    @{
        Name       = 'container-primary'
        FabricName = 'fabric-primary'
    },
    @{
        Name       = 'container-secondary'
        FabricName = 'fabric-secondary'
    }
)

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName

# Import ASR Vault Settings
$VaultSettings = Get-AzRecoveryServicesVaultSettingsFile -Vault $Vault -SiteRecovery
Import-AzRecoveryServicesAsrVaultSettingsFile -Path $VaultSettings.FilePath

# Set ASR Vault Context
Set-AzRecoveryServicesAsrVaultContext -Vault $Vault

# Create ASR Protection Containers
$ContainerJobs = @()
foreach ($Container in $Containers) {
    $Fabric = Get-AzRecoveryServicesAsrFabric -Name $Container.FabricName
    $ContainerJobs += New-AzRecoveryServicesAsrProtectionContainer -InputObject $Fabric -Name $Container.Name
}

# Monitor Protection Container Creation Jobs
do {
    $RunningJobs = @()

    foreach ($ContainerJob in $ContainerJobs) {
        $Job = Get-AzRecoveryServicesAsrJob -Job $ContainerJob

        if ($Job.State -in @('NotStarted', 'InProgress')) {
            $RunningJobs += $Job
        }
    }

    if ($RunningJobs) {
        Write-Host 'Protection Container creation jobs are still running. Checking again in 30 seconds...' -ForegroundColor Yellow
        Start-Sleep -Seconds 30
    }

} while ($RunningJobs)

# Display Final Job Results
foreach ($ContainerJob in $ContainerJobs) {
    Get-AzRecoveryServicesAsrJob -Job $ContainerJob | Format-Table TargetObjectName, JobType, State
}

# Verify Protection Container Deployment
foreach ($Container in $Containers) {
    $Fabric = Get-AzRecoveryServicesAsrFabric -Name $Container.FabricName
    Get-AzRecoveryServicesAsrProtectionContainer -Fabric $Fabric | Format-Table Name, FriendlyName
}
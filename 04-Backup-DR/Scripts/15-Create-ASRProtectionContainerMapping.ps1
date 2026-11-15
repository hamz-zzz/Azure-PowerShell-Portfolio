# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$VaultName = 'rsv-asr-secondary'
$PrimaryFabricName = 'fabric-primary'
$SecondaryFabricName = 'fabric-secondary'
$PolicyName = 'policy-asr'
$MappingName = 'mapping-primary-secondary'

# Retrieve Recovery Services Vault
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName

# Import ASR Vault Settings
$VaultSettings = Get-AzRecoveryServicesVaultSettingsFile -Vault $Vault -SiteRecovery
Import-AzRecoveryServicesAsrVaultSettingsFile -Path $VaultSettings.FilePath

# Set ASR Vault Context
Set-AzRecoveryServicesAsrVaultContext -Vault $Vault

# Retrieve ASR Fabrics
$PrimaryFabric = Get-AzRecoveryServicesAsrFabric -Name $PrimaryFabricName
$SecondaryFabric = Get-AzRecoveryServicesAsrFabric -Name $SecondaryFabricName

# Retrieve ASR Protection Containers
$PrimaryContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $PrimaryFabric
$SecondaryContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $SecondaryFabric

# Retrieve ASR Replication Policy
$Policy = Get-AzRecoveryServicesAsrPolicy -Name $PolicyName

# Create ASR Protection Container Mapping
$Job = New-AzRecoveryServicesAsrProtectionContainerMapping -Name $MappingName -Policy $Policy -PrimaryProtectionContainer $PrimaryContainer -RecoveryProtectionContainer $SecondaryContainer

# Monitor Mapping Creation Job
while ($Job.State -in @('NotStarted', 'InProgress')) {
    Write-Host 'Protection Container mapping is still running. Checking again in 30 seconds...' -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    $Job = Get-AzRecoveryServicesAsrJob -Job $Job
}

# Display Final Job Status
$Job | Format-Table TargetObjectName, JobType, State

# Verify Protection Container Mapping
Get-AzRecoveryServicesAsrProtectionContainerMapping -Name $MappingName -ProtectionContainer $PrimaryContainer
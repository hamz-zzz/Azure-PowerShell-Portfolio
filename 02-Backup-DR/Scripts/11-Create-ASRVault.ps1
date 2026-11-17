# Resource configuration
$ResourceGroupName = 'rg-recovery-secondary'
$Location = 'centralus'
$VaultName = 'rsv-asr-secondary'

# Create Recovery Services Vault
$Vault = New-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName -Location $Location

# Verify Deployment
$Vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $ResourceGroupName
$Vault | Format-Table Name, ResourceGroupName, Location
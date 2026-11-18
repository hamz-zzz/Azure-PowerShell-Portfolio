# Resource configuration
$ResourceGroups = @(
    @{
        Name     = 'rg-recovery-primary'
        Location = 'eastus2' 
    }
    @{
        Name     = 'rg-recovery-secondary'
        Location = 'centralus' 
    }
)

# Create Resource Groups
foreach ($ResourceGroup in $ResourceGroups) {
    New-AzResourceGroup -Name $ResourceGroup.Name -Location $ResourceGroup.Location
}

# Verify Deployment
foreach ($ResourceGroup in $ResourceGroups) {
    Get-AzResourceGroup -Name $ResourceGroup.Name | Format-Table ResourceGroupName, Location
}
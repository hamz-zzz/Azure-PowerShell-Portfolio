# Firewall configuration
$FirewallName = 'azfw-hub'
$ResourceGroupName = 'rg-network-hub'

# Hint: Get-AzFirewall
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName

# Deallocate Azure Firewall
$Firewall.Deallocate()

# Apply updated firewall configuration
Set-AzFirewall -AzureFirewall $Firewall

# Verify firewall deallocation
$Firewall = Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName
if ($Firewall.IpConfigurations.Count -eq 0) {
    Write-Host 'Azure Firewall is deallocated.' -ForegroundColor Green
}
else {
    Write-Host 'Azure Firewall is stll allocated.' -ForegroundColor Red
}
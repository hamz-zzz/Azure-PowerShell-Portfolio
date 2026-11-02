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

    # Delete firewall public IP resources
    Remove-AzPublicIpAddress -Name 'pip-azfw-hub' -ResourceGroupName $ResourceGroupName -Force
    Remove-AzPublicIpAddress -Name 'pip-azfw-management-hub' -ResourceGroupName $ResourceGroupName -Force

    Write-Host 'Firewall public IP resources deleted.' -ForegroundColor Green
}
else {
    Write-Host 'Azure Firewall is still allocated.' -ForegroundColor Red
}
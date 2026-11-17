# Azure Bastion configuration
$BastionName = 'bastion-hub'
$ResourceGroupName = 'rg-network-hub'
$PublicIPName = 'pip-bastion-hub'

# Delete Azure Bastion
Remove-AzBastion -Name $BastionName -ResourceGroupName $ResourceGroupName -Force
Write-Host "Azure Bastion '$BastionName' deleted."

# Delete Bastion public IP
Remove-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -Force
Write-Host "Public IP '$PublicIPName' deleted."
Write-Host 'Bastion cleanup completed.'

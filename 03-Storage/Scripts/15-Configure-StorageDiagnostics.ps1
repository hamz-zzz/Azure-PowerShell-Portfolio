# Resource configuration
$ResourceGroupName = 'rg-storage'
$Location = 'eastus2'
$StorageAccountName = 'storagehm2k'
$WorkspaceName = 'law-storage'

# Diagnostic configuration
$BlobDiagnosticName = 'diag-blob-storage'
$FilesDiagnosticName = 'diag-files-storage'
$LogCategories = @('StorageRead', 'StorageWrite', 'StorageDelete')
$Log = foreach ($LogCategory in $LogCategories) {
    New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $LogCategory
}

# Create Log Analytics workspace
$Workspace = New-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $ResourceGroupName -Location $Location

# Retrieve Storage Account
$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName

# Configure Blob service diagnostics
New-AzDiagnosticSetting -Name $BlobDiagnosticName -ResourceId "$($StorageAccount.Id)/blobServices/default" -WorkspaceId $Workspace.ResourceId -Log $Log -LogAnalyticsDestinationType Dedicated

# Configure File service diagnostics
New-AzDiagnosticSetting -Name $FilesDiagnosticName -ResourceId "$($StorageAccount.Id)/fileServices/default" -WorkspaceId $Workspace.ResourceId -Log $Log -LogAnalyticsDestinationType Dedicated

# Verify Deployment
Get-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $ResourceGroupName
Get-AzDiagnosticSetting -ResourceId "$($StorageAccount.Id)/blobServices/default"
Get-AzDiagnosticSetting -ResourceId "$($StorageAccount.Id)/fileServices/default"
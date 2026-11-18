
# Storage configuration
$StorageAccountName = 'storagehm2k'
$ShareName = 'labshare'

# Retrieve storage account key
$StorageAccountKey = Read-Host 'Storage account key' -AsSecureString
$Credential = [PSCredential]::new("localhost\$StorageAccountName", $StorageAccountKey)

# Map Azure Files share
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$StorageAccountName.file.core.windows.net\$ShareName" -Credential $Credential -Persist

# Verify Deployment
Get-PSDrive -Name Z | Format-List Name, DisplayRoot
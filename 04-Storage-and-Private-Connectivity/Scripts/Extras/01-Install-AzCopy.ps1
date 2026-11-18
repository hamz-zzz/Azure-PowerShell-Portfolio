# Installation configuration
$InstallPath = 'C:\Tools\AzCopy'
$DownloadURL = 'https://aka.ms/downloadazcopy-v10-windows'

# Create installation directory
New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null

# Download AzCopy
Invoke-WebRequest -Uri $DownloadURL -OutFile "$env:TEMP\AzCopy.zip"

# Extract AzCopy
Expand-Archive -Path "$env:TEMP\AzCopy.zip" -DestinationPath "$env:TEMP\AzCopy" -Force

# Install AzCopy
Copy-Item -Path "$env:TEMP\AzCopy\*\azcopy.exe" -Destination $InstallPath -Force

# Add AzCopy to system PATH
$MachinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
[Environment]::SetEnvironmentVariable('Path', "$MachinePath;$InstallPath", 'Machine')

# Verify Installation
& "$InstallPath\azcopy.exe" --version
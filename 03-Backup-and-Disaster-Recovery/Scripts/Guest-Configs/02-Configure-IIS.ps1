# Install IIS
Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature

# Create Guest Configuration Directory
New-Item -Path 'C:\Guest-Configs' -ItemType Directory -Force

# Create Webpage Generation Script
$WebpageScript = @'
# Retrieve VM Metadata
$Metadata = Invoke-RestMethod -Headers @{'Metadata' = 'true'} -Uri 'http://169.254.169.254/metadata/instance?api-version=2021-02-01'

$HostName = $Metadata.compute.name
$Location = $Metadata.compute.location
$PrivateIP = $Metadata.network.interface.ipv4.ipAddress[0].privateIpAddress
$PublicIP = Invoke-RestMethod -Uri 'https://api.ipify.org'

# Generate IIS Default Webpage
$HTML = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure DR Test</title>
</head>
<body>
    <h1>Azure Disaster Recovery Test</h1>
    <p>Host: $HostName</p>
    <p>Region: $Location</p>
    <p>Private IP: $PrivateIP</p>
    <p>Public IP: $PublicIP</p>
</body>
</html>
"@

Set-Content -Path 'C:\inetpub\wwwroot\index.html' -Value $HTML
'@

Set-Content -Path 'C:\Guest-Configs\03-Generate-IISWebpage.ps1' -Value $WebpageScript

# Configure Scheduled Task
$Action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\Guest-Configs\03-Generate-IISWebpage.ps1"'
$Trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -Seconds 60)
$Principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName 'Generate-IISWebpage.ps1' -Action $Action -Trigger $Trigger -Principal $Principal -Force

# Generate Initial Webpage
& 'C:\Guest-Configs\03-Generate-IISWebpage.ps1'

# Test Default Webpage
Invoke-WebRequest -Uri http://localhost -UseBasicParsing
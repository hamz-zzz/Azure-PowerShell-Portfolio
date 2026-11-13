# Install IIS
Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature

# Configure IIS Default Webpage
$Metadata = Invoke-RestMethod -Headers @{'Metadata' = 'true' } -Uri 'http://169.254.169.254/metadata/instance?api-version=2021-02-01'

$ComputerName = $Metadata.compute.name
$Location = $Metadata.compute.location

$HTML = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure DR Test</title>
</head>
<body>
    <h1>Azure Disaster Recovery Test</h1>
    <p>Server: $ComputerName</p>
    <p>Region: $Location</p>
</body>
</html>
"@

if ($(Get-Service -Name W3SVC).Status -eq 'Running') {
    Set-Content -Path 'C:\inetpub\wwwroot\index.html' -Value $HTML
}

# Test the Default Webpage
Invoke-WebRequest -Uri http://localhost
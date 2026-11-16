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
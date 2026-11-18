# Install IIS with all subfeatures
Install-WindowsFeature Web-Server -IncludeAllSubFeature

# Configure default website
Set-Content 'C:\inetpub\wwwroot\Default.htm' "IIS running on $env:COMPUTERNAME"
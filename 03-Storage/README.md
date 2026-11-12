# Project 03 - Azure Storage & Private Connectivity

![Azure Storage & Private Connectivity](Architecture/03-Storage-Private-Connectivity.svg)

## Overview

This project deploys and secures an Azure Storage Account containing Blob Storage and Azure Files, with Azure PowerShell used throughout. The work covers resource provisioning, data-plane authorization, network restrictions, Private Link, and data protection.

A Windows Server 2022 VM provides an internal client for Blob access, Azure Files over SMB, and private DNS testing. I retained its public IP for RDP administration and restricted inbound access to my current public IPv4 address.

The resources are deployed to `rg-storage` in East US 2. In the final configuration, both Storage services use Private Endpoints and public network access is disabled on the Storage Account.

## Network layout

| Component | Name | Address range / IP |
|---|---|---|
| Virtual network | `vnet-storage` | `10.0.0.0/16` |
| Subnet | `snet-storage` | `10.0.0.0/24` |
| Network security group | `nsg-storage` | Associated with `snet-storage` |
| Windows VM | `vm-windows` | `10.0.0.4` |
| Blob Private Endpoint | `private-endpoint-blob` | `10.0.0.5` |
| Files Private Endpoint | `private-endpoint-files` | `10.0.0.6` |

The VNet and subnet are created with separate address prefixes. The deployment then retrieves the VNet to verify its address space and subnet configuration:

```powershell
$VirtualNetworkAddressPrefix = '10.0.0.0/16'
$SubnetAddressPrefix = '10.0.0.0/24'

$Subnet = New-AzVirtualNetworkSubnetConfig -Name 'snet-storage' -AddressPrefix $SubnetAddressPrefix
$VirtualNetwork = New-AzVirtualNetwork -Name 'vnet-storage' -ResourceGroupName 'rg-storage' -Location 'eastus2' -AddressPrefix $VirtualNetworkAddressPrefix -Subnet $Subnet

Get-AzVirtualNetwork -Name 'vnet-storage' -ResourceGroupName 'rg-storage' |
    Select-Object Name, AddressSpace, Subnets
```

The VM and both Private Endpoints share `snet-storage`. The NSG allows RDP only from the administrator's current public IPv4 address, retrieved at deployment time and applied as a `/32` source prefix:

```powershell
$AdminPublicIP = (Invoke-RestMethod https://api.ipify.org).Trim()
$Rule = New-AzNetworkSecurityRuleConfig -Name 'Allow-RDP' -Priority 100 -Protocol Tcp -SourceAddressPrefix "$AdminPublicIP/32" -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow -Direction Inbound

$NSG = New-AzNetworkSecurityGroup -Name 'nsg-storage' -ResourceGroupName 'rg-storage' -Location 'eastus2' -SecurityRules $Rule
$VirtualNetwork = Get-AzVirtualNetwork -Name 'vnet-storage' -ResourceGroupName 'rg-storage'
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq 'snet-storage'

Set-AzVirtualNetworkSubnetConfig -Name $Subnet.Name -VirtualNetwork $VirtualNetwork -AddressPrefix $Subnet.AddressPrefix -NetworkSecurityGroup $NSG
Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork
```

**Scripts:** [Create resource group](Scripts/01-Create-ResourceGroup.ps1) · [Create network](Scripts/02-Create-Network.ps1) · [Create NSG](Scripts/03-Create-NSG.ps1)


**Screenshots:** [Resource group](Screenshots/01-Resource-Group-Overview.png) · [VNet overview](Screenshots/02-VNet-Overview.png) · [Subnet configuration](Screenshots/03-Subnet-Configuration.png) · [NSG rules](Screenshots/04-NSG-Rules.png)

## Windows client VM

`vm-windows` runs Windows Server 2022 in `snet-storage` at `10.0.0.4`. Its public IP is used for RDP administration only. Storage access is controlled separately by the Storage Account network configuration.

The deployment retrieves the VNet and subnet, creates the public IP and NIC, builds the Windows Server VM configuration, and deploys the VM:

```powershell
$VirtualNetwork = Get-AzVirtualNetwork -Name 'vnet-storage' -ResourceGroupName 'rg-storage'
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq 'snet-storage'
$Credential = Get-Credential

$PublicIP = New-AzPublicIpAddress -Name 'pip-windows' -ResourceGroupName 'rg-storage' -Location 'eastus2' -AllocationMethod Static
$NetworkInterface = New-AzNetworkInterface -Name 'nic-windows' -ResourceGroupName 'rg-storage' -Location 'eastus2' -PrivateIpAddress '10.0.0.4' -Subnet $Subnet -PublicIpAddress $PublicIP

$VMConfig = New-AzVMConfig -VMName 'vm-windows' -VMSize 'Standard_B2s_v2'
Set-AzVMOperatingSystem -VM $VMConfig -ComputerName 'vm-windows' -Credential $Credential -Windows
Set-AzVMSourceImage -VM $VMConfig -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2022-datacenter' -Version 'latest'
Set-AzVMOSDisk -VM $VMConfig -Name 'disk-windows' -StorageAccountType StandardSSD_LRS -CreateOption FromImage
Set-AzVMBootDiagnostic -VM $VMConfig -Enable
Add-AzVMNetworkInterface -VM $VMConfig -Id $NetworkInterface.Id
New-AzVM -VM $VMConfig -ResourceGroupName 'rg-storage' -Location 'eastus2'
```

During deployment, `Get-Credential` prompts for the local administrator credentials and Boot Diagnostics uses Microsoft-managed storage. A separate script enables the VM's system-assigned managed identity for Blob data access.

**Scripts:** [Create Windows VM](Scripts/04-Create-WindowsVM.ps1) · [Configure VM managed identity](Scripts/05-Configure-VMIdentity.ps1)

**Screenshots:** [Windows VM overview](Screenshots/05-Windows-VM-Overview.png) · [VM networking](Screenshots/06-Windows-VM-Networking.png) · [VM managed identity](Screenshots/07-VM-Managed-Identity.png)

## Storage Account, Blob Storage, and Azure Files

`storagehm2k` is a general-purpose v2 (`StorageV2`) account using Standard locally redundant storage (`Standard_LRS`), which replicates data within the primary region.

The account contains a Blob container and an Azure Files share:

| Resource | Name | Purpose |
|---|---|---|
| Storage Account | `storagehm2k` | Hosts Blob Storage and Azure Files |
| Blob container | `labcontainer` | Object storage and Blob data operations |
| Azure Files share | `labshare` | SMB file share |

The Storage Account is created as a general-purpose v2 account with Standard locally redundant storage. The returned resource is followed by a query to verify its configuration:

```powershell
$StorageAccount = New-AzStorageAccount -Name 'storagehm2k' -ResourceGroupName 'rg-storage' -Location 'eastus2' -Kind StorageV2 -SkuName Standard_LRS

Get-AzStorageAccount -Name 'storagehm2k' -ResourceGroupName 'rg-storage' |
    Select-Object StorageAccountName, Location, Kind, AccessTier
```

The Blob container is created using a Storage context authenticated with the signed-in Entra ID account:

```powershell
$Context = New-AzStorageContext -StorageAccountName 'storagehm2k' -UseConnectedAccount
New-AzStorageContainer -Name 'labcontainer' -Context $Context

Get-AzStorageContainer -Name 'labcontainer' -Context $Context
```

Azure Files is configured separately. The share is created using a Storage context authenticated with a Storage Account key:

```powershell
$StorageAccountKey = (Get-AzStorageAccountKey -Name 'storagehm2k' -ResourceGroupName 'rg-storage' |
    Where-Object KeyName -eq 'key1').Value
$Context = New-AzStorageContext -StorageAccountName 'storagehm2k' -StorageAccountKey $StorageAccountKey

New-AzStorageShare -Name 'labshare' -Context $Context
Get-AzStorageShare -Name 'labshare' -Context $Context
```

**Scripts:** [Create Storage Account](Scripts/06-Create-StorageAccount.ps1) · [Create Blob container](Scripts/07-Create-BlobContainer.ps1) · [Create Azure Files share](Scripts/08-Create-AzureFilesShare.ps1)

**Screenshots:** [Storage Account overview](Screenshots/08-Storage-Account-Overview.png) · [Blob container](Screenshots/09-Blob-Container.png) · [Azure Files share](Screenshots/10-Azure-Files-Share.png)


## Blob authorization with Microsoft Entra ID

Blob data access uses Microsoft Entra ID rather than a Storage Account key. I assigned the `Storage Blob Data Contributor` role at the `labcontainer` scope to two identities: the VM's system-assigned managed identity and my Entra ID user account, Hamza Mahmood (`hamza@hamzamahmood2k.onmicrosoft.com`). This allows me to validate Blob access using both identities without relying on Storage Account keys for Blob authorization.

The script retrieves the VM managed identity, identifies the signed-in Entra ID user, and constructs the container resource ID for the RBAC scope. It then assigns the role to both identities and checks the resulting assignments:

```powershell
$VirtualMachine = Get-AzVM -Name 'vm-windows' -ResourceGroupName 'rg-storage'
$UserContext = Get-AzContext
$User = Get-AzADUser -UserPrincipalName $UserContext.Account.Id
$StorageAccount = Get-AzStorageAccount -Name 'storagehm2k' -ResourceGroupName 'rg-storage'
$Scope = "$($StorageAccount.Id)/blobServices/default/containers/labcontainer"

New-AzRoleAssignment -RoleDefinitionName 'Storage Blob Data Contributor' -ObjectId $VirtualMachine.Identity.PrincipalId -Scope $Scope
New-AzRoleAssignment -RoleDefinitionName 'Storage Blob Data Contributor' -ObjectId $User.Id -Scope $Scope
```

Scoping the role assignment to `labcontainer` keeps the data permissions limited to that container. When the VM accesses Blob Storage, it can obtain a token through its managed identity rather than using a long-lived Storage Account key stored in its configuration.

**Script:** [Configure Blob RBAC](Scripts/09-Configure-BlobRBAC.ps1)

**Screenshot:** [Blob RBAC assignments](Screenshots/11-Blob-RBAC-Assignments.png)

The Storage Account firewall was tested from two public IP addresses: the approved address succeeds, while an address outside the allowlist is rejected. The successful request also uses an Entra ID identity with Blob data permissions.

### Blob request from an approved public IP

![Authorized Blob access from laptop](Screenshots/13-Laptop-Blob-Access-Authorized.png)

The firewall permits the approved source IP, while the container-scoped RBAC assignment separately authorizes the signed-in identity to perform Blob operations.

### Blob request from an unapproved public IP

![Blob access denied from an unapproved public IP](Screenshots/14-Cloudflare-Blob-Access-Denied.png)

The request is denied because its source IP is not allowed by the Storage Account firewall. A valid Blob identity does not bypass this network restriction.


## Storage firewall and service endpoint

Before implementing Private Link, a `Microsoft.Storage` service endpoint was configured on `snet-storage`, and the subnet and administrator public IP were added to the Storage Account firewall. The default network action is `Deny`.

The script retrieves the VNet and subnet, enables the `Microsoft.Storage` service endpoint, adds the subnet and administrator public IP to the Storage Account firewall, and sets the default network action to `Deny`:

```powershell
$VirtualNetwork = Get-AzVirtualNetwork -Name 'vnet-storage' -ResourceGroupName 'rg-storage'
$Subnet = $VirtualNetwork.Subnets | Where-Object Name -eq 'snet-storage'

Set-AzVirtualNetworkSubnetConfig -Name $Subnet.Name -VirtualNetwork $VirtualNetwork -AddressPrefix $Subnet.AddressPrefix -NetworkSecurityGroup $Subnet.NetworkSecurityGroup -ServiceEndpoint Microsoft.Storage
Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork
Add-AzStorageAccountNetworkRule -Name 'storagehm2k' -ResourceGroupName 'rg-storage' -VirtualNetworkResourceId $Subnet.Id
Add-AzStorageAccountNetworkRule -Name 'storagehm2k' -ResourceGroupName 'rg-storage' -IPAddressOrRange $AdminPublicIP
Update-AzStorageAccountNetworkRuleSet -Name 'storagehm2k' -ResourceGroupName 'rg-storage' -DefaultAction Deny
```

I used the service endpoint as a comparison with Private Link. It provides subnet-based access to the public Storage endpoint, but does not assign a private IP. Private Link instead provides a private IP for each selected Storage subresource. This service endpoint configuration is an earlier comparison exercise, not part of the final access path.

**Script:** [Configure Storage service endpoint and network rules](Scripts/10-Configure-StorageServiceEndpoint.ps1)

### Service endpoint and Storage firewall configuration

![Service endpoint and Storage firewall rules](Screenshots/12-Service-Endpoint-Firewall-Rules.png)

The screenshot shows the subnet service endpoint and the Storage Account firewall allowlist. This intermediate configuration restricts access to approved networks while still using the public Storage endpoint.

## Private DNS and Private Endpoints

Blob Storage and Azure Files use separate Private Endpoints because they are distinct Storage subresources. Each endpoint has its own private DNS zone, linked to `vnet-storage`.

| Storage service | Private Endpoint | Private IP | Private DNS zone |
|---|---|---|---|
| Blob | `private-endpoint-blob` | `10.0.0.5` | `privatelink.blob.core.windows.net` |
| Azure Files | `private-endpoint-files` | `10.0.0.6` | `privatelink.file.core.windows.net` |

The VNet links make the private DNS zones available to clients in `vnet-storage`. Clients continue using the standard Storage FQDNs, such as `storagehm2k.blob.core.windows.net` and `storagehm2k.file.core.windows.net`, rather than `privatelink` names.

Inside the VNet, DNS follows a CNAME chain from the normal service FQDN to its corresponding `privatelink` FQDN. For Blob, `storagehm2k.blob.core.windows.net` aliases to `storagehm2k.privatelink.blob.core.windows.net`, which resolves through the private DNS zone to `10.0.0.5`. Azure Files follows the same pattern through `storagehm2k.privatelink.file.core.windows.net`, resolving to `10.0.0.6`. This is the key role of the private DNS zones: they make the standard service names resolve to the Private Endpoint addresses for clients using the linked VNet.

The DNS script retrieves `vnet-storage`, creates the two service-specific private DNS zones, links both zones to the VNet, and verifies the zones and links:

```powershell
$VirtualNetwork = Get-AzVirtualNetwork -Name 'vnet-storage' -ResourceGroupName 'rg-storage'
New-AzPrivateDnsZone -Name 'privatelink.blob.core.windows.net' -ResourceGroupName 'rg-storage'
New-AzPrivateDnsZone -Name 'privatelink.file.core.windows.net' -ResourceGroupName 'rg-storage'

New-AzPrivateDnsVirtualNetworkLink -Name 'link-blob-storage-vnet' -ZoneName 'privatelink.blob.core.windows.net' -VirtualNetwork $VirtualNetwork -ResourceGroupName 'rg-storage'
New-AzPrivateDnsVirtualNetworkLink -Name 'link-file-storage-vnet' -ZoneName 'privatelink.file.core.windows.net' -VirtualNetwork $VirtualNetwork -ResourceGroupName 'rg-storage'
```

The endpoint script retrieves the VNet, subnet, Storage Account, and private DNS zones. It creates a service connection and static IP configuration for each Storage subresource, deploys both endpoints, associates each endpoint with its DNS zone, and verifies endpoint provisioning and DNS records:

```powershell
$StorageAccount = Get-AzStorageAccount -Name 'storagehm2k' -ResourceGroupName 'rg-storage'
$Subnet = (Get-AzVirtualNetwork -Name 'vnet-storage' -ResourceGroupName 'rg-storage').Subnets |
    Where-Object Name -eq 'snet-storage'

$BlobConnection = New-AzPrivateLinkServiceConnection -Name 'blob-connection' -PrivateLinkServiceId $StorageAccount.Id -GroupId blob
$FilesConnection = New-AzPrivateLinkServiceConnection -Name 'files-connection' -PrivateLinkServiceId $StorageAccount.Id -GroupId file
$BlobIPConfig = New-AzPrivateEndpointIpConfiguration -Name 'blob-ipconfig' -GroupId blob -MemberName blob -PrivateIpAddress '10.0.0.5'
$FilesIPConfig = New-AzPrivateEndpointIpConfiguration -Name 'files-ipconfig' -GroupId file -MemberName file -PrivateIpAddress '10.0.0.6'

New-AzPrivateEndpoint -Name 'private-endpoint-blob' -ResourceGroupName 'rg-storage' -Location 'eastus2' -Subnet $Subnet -PrivateLinkServiceConnection $BlobConnection -IpConfiguration $BlobIPConfig
New-AzPrivateEndpoint -Name 'private-endpoint-files' -ResourceGroupName 'rg-storage' -Location 'eastus2' -Subnet $Subnet -PrivateLinkServiceConnection $FilesConnection -IpConfiguration $FilesIPConfig
```

Each endpoint is associated with its DNS zone through a DNS zone group. Azure maintains the records mapping the Storage service hostnames to the endpoint's private IP address.

**Scripts:** [Create Private DNS zones and VNet links](Scripts/11-Create-PrivateDNS.ps1) · [Create Private Endpoints and DNS zone groups](Scripts/12-Create-PrivateEndpoints.ps1)

DNS resolution was checked from `vm-windows` before and after Private Endpoint deployment. The standard Storage FQDNs initially resolve to public addresses. After deployment, each follows a CNAME to its `privatelink` FQDN and resolves to the corresponding Private Endpoint IP.

### DNS resolution before Private Endpoint deployment

![DNS resolution before Private Endpoint creation](Screenshots/18.1-Pre-Private-Endpoint-DNS-Resolution.png)

The standard Storage FQDNs resolve to public addresses before the Private Endpoints are deployed.

### DNS resolution after Private Endpoint deployment

![DNS resolution after Private Endpoint creation](Screenshots/18.2-Post-Private-Endpoint-DNS-Resolution.png)

The standard FQDNs now CNAME to their `privatelink` FQDNs. The private DNS zones return `10.0.0.5` for Blob and `10.0.0.6` for Azure Files, directing clients to the Private Endpoints.

The supporting configuration evidence remains available here: [Blob Private DNS zone](Screenshots/19.1-Blob-Private-DNS-Zone.png) · [Blob DNS VNet link](Screenshots/19.2-Blob-DNS-VNet-Link.png) · [Files Private DNS zone](Screenshots/19.3-Files-Private-DNS-Zone.png) · [Files DNS VNet link](Screenshots/19.4-Files-DNS-VNet-Link.png) · [Private Endpoint connections](Screenshots/20-Private-Endpoint-Connections.png) · [Blob Private DNS configuration](Screenshots/21.1-Blob-Private-DNS-Configuration.png) · [Files Private DNS configuration](Screenshots/21.2-Files-Private-DNS-Configuration.png)

### Private Endpoint service-port connectivity

![Private Endpoint connectivity tests](Screenshots/22-Private-Endpoint-Connectivity.png)

The VM successfully connects to TCP 443 for Blob Storage and TCP 445 for Azure Files, confirming service-port reachability through both Private Endpoints.

## Disable public network access

After validating the Private Endpoints and DNS resolution, public network access was disabled on `storagehm2k`:

```powershell
Set-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -PublicNetworkAccess Disabled

Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName |
    Select-Object StorageAccountName, PublicNetworkAccess
```

This leaves Private Link as the Storage Account's access path. The service endpoint and firewall rules were part of the earlier comparison exercise. They are not required for the final configuration, which has public network access disabled.

**Script:** [Disable Storage Account public network access](Scripts/13-Disable-PublicAccess.ps1)

### Storage Account public network access disabled

![Storage public network access disabled](Screenshots/23-Storage-Public-Network-Access-Disabled.png)

I used AzCopy to validate the final access model. From `vm-windows`, the standard Blob FQDN resolves through the `privatelink` CNAME to `10.0.0.5`, and the transfer succeeds through the Private Endpoint. From the laptop, the public endpoint request is blocked because public network access is disabled.

### AzCopy transfer through the Blob Private Endpoint

![AzCopy access from the VM through the private endpoint](Screenshots/24-VM-AzCopy-Private-Endpoint-Access.png)

The successful transfer confirms private DNS resolution, endpoint connectivity, authentication, and Blob data access.

### Public endpoint access blocked from my laptop

![Public endpoint access blocked from the laptop](Screenshots/25-Laptop-AzCopy-Public-Endpoint-Blocked.png)

The laptop cannot use the VNet's private DNS resolution, and the Storage Account's public endpoint is disabled, so the request is blocked.


## Azure Files over SMB

`vm-windows` connects to `labshare` over SMB through the Files Private Endpoint. The script prompts for the Storage Account key at runtime before mapping the share as a persistent PowerShell drive:

```powershell
$StorageAccountKey = Read-Host 'Storage account key' -AsSecureString
$Credential = [PSCredential]::new("localhost\$StorageAccountName", $StorageAccountKey)
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$StorageAccountName.file.core.windows.net\$ShareName" -Credential $Credential -Persist
```

For this project, Azure Files uses Storage Account key authentication. This is separate from the Entra ID and managed identity authorization configured for Blob Storage. The Blob RBAC assignments do not provide identity-based SMB authentication.

The UNC path uses the standard Files FQDN, `storagehm2k.file.core.windows.net`. Private DNS resolves it through `privatelink.file.core.windows.net` to `10.0.0.6`, directing SMB traffic through the Files Private Endpoint.

**Additional script:** [Connect Azure Files share](Scripts/Extras/02-Connect-AzureFilesShare.ps1)


### Azure Files SMB connection

The mapped drive confirms an SMB session to `labshare` through the Files Private Endpoint using the Storage Account key.

![Azure Files SMB connection](Screenshots/26-Azure-Files-SMB-Connection.png)

### Azure Files read and write validation

The test confirms that the mapped share supports both file writes and reads.

![Azure Files read and write validation](Screenshots/27-Azure-Files-Read-Write-Test.png)


## Storage data protection

Blob versioning and seven-day soft delete are enabled for blobs, containers, and Azure Files shares. Versioning retains previous Blob versions, while soft delete provides a recovery window for deleted data.

```powershell
$BlobProperties = Get-AzStorageBlobServiceProperty -StorageAccountName 'storagehm2k' -ResourceGroupName 'rg-storage'
$FileProperties = Get-AzStorageFileServiceProperty -StorageAccountName 'storagehm2k' -ResourceGroupName 'rg-storage'

Update-AzStorageBlobServiceProperty -StorageAccountName 'storagehm2k' -ResourceGroupName 'rg-storage' -IsVersioningEnabled $true
Enable-AzStorageBlobDeleteRetentionPolicy -StorageAccountName 'storagehm2k' -ResourceGroupName 'rg-storage' -RetentionDays 7
Enable-AzStorageContainerDeleteRetentionPolicy -StorageAccountName 'storagehm2k' -ResourceGroupName 'rg-storage' -RetentionDays 7
Update-AzStorageFileServiceProperty -StorageAccountName 'storagehm2k' -ResourceGroupName 'rg-storage' -EnableShareDeleteRetentionPolicy $true -ShareRetentionDays 7

Get-AzStorageBlobServiceProperty -StorageAccountName 'storagehm2k' -ResourceGroupName 'rg-storage'
Get-AzStorageFileServiceProperty -StorageAccountName 'storagehm2k' -ResourceGroupName 'rg-storage'
```

**Script:** [Configure Storage data protection](Scripts/14-Configure-StorageProtection.ps1)

### Blob and Azure Files data protection settings

![Storage data protection settings](Screenshots/28-Storage-Data-Protection.png)

The screenshot confirms the configured versioning and seven-day soft-delete policies. The recovery tests verify that the settings work as expected.

### Recovery tests

The following tests validate recovery for Blob versions, deleted Blobs, containers, and Azure Files shares.

| Recovery operation | Recovery evidence |
|---|---|
| **Restore a previous Blob version** | ![Blob version history](Screenshots/29-Blob-Version-History.png) ![Blob version restoration operation](Screenshots/30-Blob-Version-Restoration.png) ![Blob version restoration validation](Screenshots/31-Blob-Restoration-Validation.png) |
| **Recover a soft-deleted Blob** | ![Deleted Blob](Screenshots/32-Blob-Soft-Delete.png) ![Blob soft-delete recovery operation](Screenshots/33-Blob-Soft-Delete-Restoration.png) ![Blob recovery validation](Screenshots/34-Blob-Soft-Delete-Validation.png) |
| **Restore a deleted container** | ![Deleted container](Screenshots/35-Container-Soft-Deleted.png) ![Container restoration](Screenshots/36-Container-Restoration.png) |
| **Restore a deleted Azure Files share** | ![Deleted Azure Files share](Screenshots/37-Azure-Files-Share-Soft-Deleted.png) ![Azure Files share restoration](Screenshots/38-Azure-Files-Share-Restoration.png) |

## Additional scripts

The `Extras/` directory contains two additional PowerShell scripts:

- [Install AzCopy](Scripts/Extras/01-Install-AzCopy.ps1) - downloads AzCopy, installs it under `C:\Tools\AzCopy`, adds the directory to the machine PATH, and checks the installed version.
- [Connect Azure Files share](Scripts/Extras/02-Connect-AzureFilesShare.ps1) - maps `labshare` as a persistent PowerShell drive using the Storage Account key.

## Project files

- `Architecture/` - architecture diagram and exported PNG/SVG versions.
- `Scripts/` - Azure PowerShell deployment and configuration scripts.
- `Scripts/Extras/` - additional PowerShell scripts for installing AzCopy and connecting to the Azure Files share.
- `Screenshots/` - Azure configuration, connectivity tests, storage operations, and recovery evidence.
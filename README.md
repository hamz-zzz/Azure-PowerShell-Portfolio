# Azure PowerShell Portfolio

## Introduction

As part of my interest in IT and networking, I wanted to learn more about cloud computing. I started learning AWS earlier in the year and later decided to expand my knowledge to Azure. Before getting into Azure, I spent the summer learning PowerShell by reading Learn PowerShell in a Month of Lunches and Learn PowerShell Scripting in a Month of Lunches. I wanted to get comfortable with PowerShell before using it with Azure. With help from courses by John Savill and Alan Rodrigues, along with hands-on labs, I studied for and passed the Azure Administrator (AZ-104) exam.

After passing the AZ-104 exam, I took Alan Rodrigues' Azure PowerShell course on Udemy. Choosing his course was an easy decision since I had also used his AZ-104 course to prepare for the exam. I saw it as a way to review both the PowerShell and Azure concepts I had learned and get more comfortable using them together. The course gave me the idea to build these projects using Azure PowerShell.

This repository brings together four projects covering compute, networking, backup and disaster recovery, and storage. Each project documents the resources deployed, how they were configured, and how they were tested.

## Projects

### [1. Compute & Web Infrastructure](01-Compute-and-Web-Infrastructure/README.md)

![Project 01 architecture](01-Compute-and-Web-Infrastructure/Architecture/01-Compute-and-Web-Infrastructure.png)

This project deploys four web servers in Azure: two Windows Server VMs running IIS and two Ubuntu VMs running NGINX. An Azure Standard Load Balancer provides separate public endpoints for the Windows and Linux workloads and distributes HTTP traffic across each pair of servers. Health probes monitor the backend instances, while inbound NAT rules provide administrative access through the VMs' private IP addresses. Explicit outbound connectivity and public DNS records are also configured for the web endpoints, allowing the servers to remain on private IP addresses while serving traffic through the load balancer.

### [2. Hub-and-Spoke Networking](02-Hub-and-Spoke-Networking/README.md)

![Project 02 architecture](02-Hub-and-Spoke-Networking/Architecture/02-Hub-and-Spoke-Networking.png)

This project builds a hub-and-spoke network in Azure to centralize traffic inspection and provide secure access to private workloads. A workload VNet connects to a central hub through VNet peering, where Azure Firewall filters and inspects workload traffic using configured routes and firewall rules. Azure Bastion provides administrative access to Windows Server and Ubuntu test VMs without requiring public IP addresses on the VMs. Firewall diagnostics are sent to Log Analytics for monitoring and review, while the test VMs are used to validate private connectivity, DNS resolution, and controlled outbound access through the hub.

### [3. Backup & Disaster Recovery](03-Backup-and-Disaster-Recovery/README.md)

![Project 03 architecture](03-Backup-and-Disaster-Recovery/Architecture/03-Backup-and-Disaster-Recovery.png)

This project deploys a Windows Server workload in East US 2 and implements two recovery paths. Azure Backup provides scheduled VM backups and file-level recovery, while Azure Site Recovery replicates the workload to Central US for regional disaster recovery. Backup policies, recovery points, replication, and recovery job monitoring are configured to manage and track the recovery process. A test failover is performed in the secondary region to verify that the replicated VM can be recovered and the workload brought back online.

### [4. Storage & Private Connectivity](04-Storage-and-Private-Connectivity/README.md)

![Project 04 architecture](04-Storage-and-Private-Connectivity/Architecture/04-Storage-and-Private-Connectivity.png)

This project secures Azure Blob Storage and Azure Files through network restrictions, private connectivity, and controlled access. A Windows Server VM is deployed to validate access to both services. Blob access uses Microsoft Entra ID and a system-assigned managed identity, while Azure Files is accessed over SMB using the Storage Account key. Private Endpoints and private DNS provide connectivity to both services, with public network access disabled on the Storage Account. Blob versioning and soft delete are configured for Blobs, containers, and Azure Files shares. Recovery tests verify that the data can be restored.
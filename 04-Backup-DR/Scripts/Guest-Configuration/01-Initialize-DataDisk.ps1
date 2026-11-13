# Identify the newly attached data disk
$Disk = Get-Disk | Where-Object PartitionStyle -eq 'RAW'

# Initialize disk using GPT
Initialize-Disk -Number $Disk.Number -PartitionStyle GPT

# Create partition and assign drive letter
$Partition = New-Partition -DiskNumber $Disk.Number -UseMaximumSize -DriveLetter D

# Format partition with NTFS
Format-Volume -Partition $Partition -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false

# Create recovery test directory
New-Item -Path 'D:\Recovery-Test' -ItemType Directory

# Create sample files
'Azure Backup test file' | Set-Content 'D:\Recovery-Test\backup-test.txt'
'File recovery validation' | Set-Content 'D:\Recovery-Test\file-recovery-test.txt'

# Verify configuration
Get-Disk -Number $Disk.Number
Get-Volume -DriveLetter D
Get-ChildItem 'D:\Recovery-Test'
# Resource configuration
$ResourceGroupName = 'rg-storage'
$StorageAccountName = 'storagehm2k'
$ContainerName = 'labcontainer'
$VirtualMachineName = 'vm-windows'
$RoleDefinitionName = 'Storage Blob Data Contributor'

# Retrieve virtual machine
$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName

# Retrieve current user
$UserContext = Get-AzContext
$User = Get-AzADUser -UserPrincipalName $UserContext.Account.Id

# Retrieve storage account
$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName

# Construct container resource ID for RBAC scope
$Scope = "$($StorageAccount.Id)/blobServices/default/containers/$ContainerName"

# Assign role to VM managed identity
New-AzRoleAssignment -RoleDefinitionName $RoleDefinitionName -ObjectId $VirtualMachine.Identity.PrincipalId -Scope $Scope

# Assign role to current user
New-AzRoleAssignment -RoleDefinitionName $RoleDefinitionName -ObjectId $User.Id -Scope $Scope

Get-AzRoleAssignment -Scope $Scope -RoleDefinitionName $RoleDefinitionName | Select-Object DisplayName, ObjectType, ObjectId, RoleDefinitionName, @{Name = 'Container'; Expression = {Split-Path $_.Scope -Leaf}} | Format-Table
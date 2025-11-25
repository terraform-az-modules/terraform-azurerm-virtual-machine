##-----------------------------------------------------------------------------
## Network Interface Outputs
##-----------------------------------------------------------------------------
output "network_interface_id" {
  value       = azurerm_network_interface.default[0].id
  description = "The ID of the Network Interface."
}

output "network_interface_private_ip_addresses" {
  value       = try(azurerm_network_interface.default[*].private_ip_addresses, null)
  description = "The private IP addresses of the network interface."
}

output "network_interface_sg_association_id" {
  value       = try(azurerm_network_interface_security_group_association.default[*].id, null)
  description = "The (Terraform specific) ID of the Association between the Network Interface and the Network Interface."
}

##-----------------------------------------------------------------------------
## Availability Set Outputs
##-----------------------------------------------------------------------------
output "availability_set_id" {
  value       = try(azurerm_availability_set.default[*].id, null)
  description = "The ID of the Availability Set."
}

##-----------------------------------------------------------------------------
## Public IP Outputs
##-----------------------------------------------------------------------------
output "public_ip_id" {
  value       = try(azurerm_public_ip.default[*].id, null)
  description = "The Public IP ID."
}

output "public_ip_address" {
  value       = try(azurerm_public_ip.default[*].ip_address, null)
  description = "The IP address value that was allocated."
}

##-----------------------------------------------------------------------------
## Virtual Machine Outputs
##-----------------------------------------------------------------------------
output "linux_virtual_machine_id" {
  value       = try(azurerm_linux_virtual_machine.default[0].id, null)
  description = "The ID of the Linux Virtual Machine."
}

output "windows_virtual_machine_id" {
  value       = try(azurerm_windows_virtual_machine.win_vm[0].id, null)
  description = "The ID of the Windows Virtual Machine."
}

##-----------------------------------------------------------------------------
## Disk Encryption Outputs
##-----------------------------------------------------------------------------
output "disk_encryption_set_id" {
  value       = try(azurerm_disk_encryption_set.main[*].id, null)
  description = "The ID of the Disk Encryption Set."
}

output "key_id" {
  value       = try(azurerm_key_vault_key.main[*].id, null)
  description = "ID of key that is used for disk encryption."
}

##-----------------------------------------------------------------------------
## VM Extension Outputs
##-----------------------------------------------------------------------------
output "extension_id" {
  value       = { for id in azurerm_virtual_machine_extension.vm_insight_monitor_agent : id.name => id.id }
  description = "The ID of the Virtual Machine Extension."
}

##-----------------------------------------------------------------------------
## Backup Outputs
##-----------------------------------------------------------------------------
output "service_vault_id" {
  description = "The Principal ID associated with this Managed Service Identity."
  value       = try(azurerm_recovery_services_vault.main[*].identity[0].principal_id, null)
}

output "service_vault_tenant_id" {
  description = "The Tenant ID associated with this Managed Service Identity."
  value       = try(azurerm_recovery_services_vault.main[*].identity[0].tenant_id, null)
}

output "vm_backup_policy_id" {
  description = "The ID of the VM Backup Policy."
  value       = try(azurerm_backup_policy_vm.policy[0].id, [])
}

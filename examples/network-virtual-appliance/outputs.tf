##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "virtual_machine_id" {
  value       = module.nva.linux_virtual_machine_id
  description = "The ID of the Virtual Machine."
}

output "additional_network_interface_ids" {
  value       = module.nva.additional_network_interface_ids
  description = "Map of additional network interface names to their IDs."
}

output "additional_public_ip_addresses" {
  value       = module.nva.additional_public_ip_addresses
  description = "Map of additional network interface names to their public IP address."
}

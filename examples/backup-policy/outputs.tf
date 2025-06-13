
output "network_interface_private_ip_addresses" {
  value       = module.virtual-machine.network_interface_private_ip_addresses
  description = "The private IP addresses of the network interface."
}

output "availability_set_id" {
  value       = module.virtual-machine.availability_set_id
  description = "The ID of the Availability Set."
}

output "public_ip_address" {
  value       = module.virtual-machine.public_ip_address
  description = "The IP address value that was allocated."
}

output "public_ip_id" {
  value       = module.virtual-machine.public_ip_id
  description = "The Public IP ID."
}

output "virtual_machine_id" {
  value       = module.virtual-machine.linux_virtual_machine_id
  description = "The ID of the Virtual Machine."
}

output "tags" {
  value       = module.virtual-machine.tags
  description = "The tags associated to resources."
}

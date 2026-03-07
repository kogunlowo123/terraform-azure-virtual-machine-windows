output "vm_id" {
  description = "The ID of the Windows Virtual Machine."
  value       = azurerm_windows_virtual_machine.this.id
}

output "vm_name" {
  description = "The name of the Windows Virtual Machine."
  value       = azurerm_windows_virtual_machine.this.name
}

output "private_ip_address" {
  description = "The primary private IP address of the VM."
  value       = azurerm_windows_virtual_machine.this.private_ip_address
}

output "public_ip_address" {
  description = "The primary public IP address of the VM."
  value       = azurerm_windows_virtual_machine.this.public_ip_address
}

output "identity" {
  description = "The identity block of the VM."
  value       = try(azurerm_windows_virtual_machine.this.identity[0], null)
}

output "computer_name" {
  description = "The computer name of the VM."
  value       = azurerm_windows_virtual_machine.this.computer_name
}

output "network_interface_id" {
  description = "The ID of the auto-created network interface."
  value       = local.create_nic ? azurerm_network_interface.this[0].id : null
}

output "network_interface_private_ip" {
  description = "The private IP address of the auto-created network interface."
  value       = local.create_nic ? azurerm_network_interface.this[0].private_ip_address : null
}

output "public_ip_id" {
  description = "The ID of the public IP address."
  value       = var.create_public_ip && local.create_nic ? azurerm_public_ip.this[0].id : null
}

output "public_ip_address_value" {
  description = "The actual public IP address value."
  value       = var.create_public_ip && local.create_nic ? azurerm_public_ip.this[0].ip_address : null
}

output "data_disk_ids" {
  description = "Map of data disk names to their IDs."
  value       = { for k, v in azurerm_managed_disk.this : k => v.id }
}

output "vm_resource_id" {
  description = "The full Azure Resource ID of the VM."
  value       = azurerm_windows_virtual_machine.this.id
}

locals {
  # Determine if we need to create a NIC
  create_nic = length(var.network_interface_ids) == 0

  # NIC IDs to attach
  network_interface_ids = local.create_nic ? [azurerm_network_interface.this[0].id] : var.network_interface_ids

  # Computer name
  computer_name = var.computer_name != null ? var.computer_name : var.name

  # Backup resource group
  backup_resource_group_name = var.backup_resource_group_name != null ? var.backup_resource_group_name : var.resource_group_name

  # Antimalware settings JSON
  antimalware_settings = jsonencode({
    AntimalwareEnabled = true
    RealtimeProtectionEnabled = try(var.antimalware_settings.real_time_protection_enabled, true) ? "true" : "false"
    ScheduledScanSettings = {
      isEnabled = try(var.antimalware_settings.scheduled_scan_enabled, true) ? "true" : "false"
      scanType  = try(var.antimalware_settings.scheduled_scan_type, "Quick")
      day       = try(var.antimalware_settings.scheduled_scan_day, 7)
      time      = try(var.antimalware_settings.scheduled_scan_time, 120)
    }
    Exclusions = {
      Extensions = try(var.antimalware_settings.exclusions_extensions, "")
      Paths      = try(var.antimalware_settings.exclusions_paths, "")
      Processes  = try(var.antimalware_settings.exclusions_processes, "")
    }
  })

  # Default tags
  default_tags = {
    ManagedBy = "Terraform"
    Module    = "terraform-azure-virtual-machine-windows"
  }

  merged_tags = merge(local.default_tags, var.tags)
}

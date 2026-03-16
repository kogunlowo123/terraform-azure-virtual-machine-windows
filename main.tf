resource "azurerm_public_ip" "this" {
  count = var.create_public_ip && length(var.network_interface_ids) == 0 ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.public_ip_sku
  zones               = var.zone != null ? [var.zone] : []

  tags = var.tags
}

resource "azurerm_network_interface" "this" {
  count = length(var.network_interface_ids) == 0 ? 1 : 0

  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address_allocation == "Static" ? var.private_ip_address : null
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.this[0].id : null
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "this" {
  name                           = var.name
  resource_group_name            = var.resource_group_name
  location                       = var.location
  size                           = var.size
  admin_username                 = var.admin_username
  admin_password                 = var.admin_password
  computer_name                  = var.computer_name != null ? var.computer_name : var.name
  network_interface_ids          = length(var.network_interface_ids) > 0 ? var.network_interface_ids : [azurerm_network_interface.this[0].id]
  zone                           = var.zone
  availability_set_id            = var.availability_set_id
  proximity_placement_group_id   = var.proximity_placement_group_id
  license_type                   = var.license_type
  enable_automatic_updates       = var.enable_automatic_updates
  patch_mode                     = var.patch_mode
  patch_assessment_mode          = var.patch_assessment_mode
  hotpatching_enabled            = var.hotpatching_enabled
  timezone                       = var.timezone
  provision_vm_agent             = var.provision_vm_agent
  encryption_at_host_enabled     = var.encryption_at_host_enabled
  secure_boot_enabled            = var.secure_boot_enabled
  vtpm_enabled                   = var.vtpm_enabled
  allow_extension_operations     = var.allow_extension_operations
  custom_data                    = var.custom_data
  user_data                      = var.user_data

  os_disk {
    caching                          = var.os_disk.caching
    storage_account_type             = var.os_disk.storage_account_type
    disk_size_gb                     = var.os_disk.disk_size_gb
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled
    security_encryption_type         = var.os_disk.security_encryption_type
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [var.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  source_image_id = var.source_image_id

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  dynamic "winrm_listener" {
    for_each = var.winrm_listeners
    content {
      protocol        = winrm_listener.value.protocol
      certificate_url = winrm_listener.value.certificate_url
    }
  }

  dynamic "additional_unattend_content" {
    for_each = var.additional_unattend_content
    content {
      setting = additional_unattend_content.value.setting
      content = additional_unattend_content.value.content
    }
  }

  tags = var.tags
}

resource "azurerm_managed_disk" "this" {
  for_each = var.data_disks

  name                   = "${var.name}-disk-${each.key}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  storage_account_type   = each.value.storage_account_type
  create_option          = each.value.create_option
  disk_size_gb           = each.value.disk_size_gb
  disk_encryption_set_id = each.value.disk_encryption_set_id
  tier                   = each.value.tier
  zone                   = each.value.zone != null ? each.value.zone : var.zone

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = var.data_disks

  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = each.value.lun
  caching            = each.value.caching
}

resource "azurerm_virtual_machine_extension" "antimalware" {
  count = var.enable_antimalware_extension ? 1 : 0

  name                       = "IaaSAntimalware"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    AntimalwareEnabled          = true
    RealtimeProtectionEnabled   = var.antimalware_settings.real_time_protection_enabled ? "true" : "false"
    ScheduledScanSettings = {
      isEnabled = var.antimalware_settings.scheduled_scan_enabled ? "true" : "false"
      scanType  = var.antimalware_settings.scheduled_scan_type
      day       = var.antimalware_settings.scheduled_scan_day
      time      = var.antimalware_settings.scheduled_scan_time
    }
    Exclusions = {
      Extensions = var.antimalware_settings.exclusions_extensions
      Paths      = var.antimalware_settings.exclusions_paths
      Processes  = var.antimalware_settings.exclusions_processes
    }
  })

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "monitoring" {
  count = var.enable_monitoring_extension ? 1 : 0

  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  count = var.enable_azure_ad_login ? 1 : 0

  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "custom" {
  for_each = var.custom_extensions

  name                       = each.key
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = each.value.publisher
  type                       = each.value.type
  type_handler_version       = each.value.type_handler_version
  auto_upgrade_minor_version = each.value.auto_upgrade_minor_version
  automatic_upgrade_enabled  = each.value.automatic_upgrade_enabled
  settings                   = each.value.settings
  protected_settings         = each.value.protected_settings

  tags = var.tags
}

resource "azurerm_backup_protected_vm" "this" {
  count = var.backup_policy_id != null ? 1 : 0

  resource_group_name = var.backup_resource_group_name != null ? var.backup_resource_group_name : var.resource_group_name
  recovery_vault_name = var.recovery_vault_name
  source_vm_id        = azurerm_windows_virtual_machine.this.id
  backup_policy_id    = var.backup_policy_id
}

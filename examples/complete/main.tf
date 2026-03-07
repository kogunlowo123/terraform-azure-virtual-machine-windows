provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-vm-complete"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-vms"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_proximity_placement_group" "example" {
  name                = "ppg-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_storage_account" "diagnostics" {
  name                     = "stdiagvmcomplete"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_recovery_services_vault" "example" {
  name                = "rsv-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
  soft_delete_enabled = false
}

resource "azurerm_backup_policy_vm" "example" {
  name                = "policy-vm-daily"
  resource_group_name = azurerm_resource_group.example.name
  recovery_vault_name = azurerm_recovery_services_vault.example.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }

  retention_weekly {
    count    = 12
    weekdays = ["Sunday"]
  }
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "id-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

module "windows_vm" {
  source = "../../"

  name                         = "vm-complete-01"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  size                         = "Standard_D8s_v3"
  admin_username               = "azureadmin"
  admin_password               = "P@ssw0rd1234!#Complex"
  subnet_id                    = azurerm_subnet.example.id
  zone                         = "1"
  proximity_placement_group_id = azurerm_proximity_placement_group.example.id
  create_public_ip             = false
  license_type                 = "Windows_Server"
  timezone                     = "Eastern Standard Time"
  enable_automatic_updates     = true
  patch_mode                   = "AutomaticByPlatform"
  patch_assessment_mode        = "AutomaticByPlatform"
  provision_vm_agent           = true
  encryption_at_host_enabled   = true
  secure_boot_enabled          = true
  vtpm_enabled                 = true
  identity_type                = "SystemAssigned, UserAssigned"
  identity_ids                 = [azurerm_user_assigned_identity.example.id]

  private_ip_address_allocation = "Static"
  private_ip_address            = "10.0.1.10"

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 256
  }

  data_disks = {
    "data" = {
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 512
      lun                  = 0
      caching              = "ReadOnly"
    }
    "logs" = {
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 128
      lun                  = 1
      caching              = "None"
    }
    "temp" = {
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 64
      lun                  = 2
      caching              = "None"
    }
  }

  enable_boot_diagnostics              = true
  boot_diagnostics_storage_account_uri = azurerm_storage_account.diagnostics.primary_blob_endpoint

  enable_antimalware_extension = true
  antimalware_settings = {
    real_time_protection_enabled = true
    scheduled_scan_enabled       = true
    scheduled_scan_type          = "Full"
    scheduled_scan_day           = 7
    scheduled_scan_time          = 120
    exclusions_paths             = "C:\\Temp;D:\\Logs"
    exclusions_extensions        = ".log;.tmp"
    exclusions_processes         = "taskmgr.exe"
  }

  enable_monitoring_extension = true
  enable_azure_ad_login       = true

  backup_policy_id    = azurerm_backup_policy_vm.example.id
  recovery_vault_name = azurerm_recovery_services_vault.example.name

  tags = {
    Environment = "production"
    Project     = "example"
    CostCenter  = "IT-001"
    Backup      = "enabled"
  }
}

output "vm_id" {
  value = module.windows_vm.vm_id
}

output "private_ip" {
  value = module.windows_vm.private_ip_address
}

output "identity" {
  value = module.windows_vm.identity
}

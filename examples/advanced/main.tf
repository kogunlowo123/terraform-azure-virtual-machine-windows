provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-vm-advanced"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-vm-advanced"
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

resource "azurerm_availability_set" "example" {
  name                         = "avset-vm-advanced"
  location                     = azurerm_resource_group.example.location
  resource_group_name          = azurerm_resource_group.example.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}

module "windows_vm" {
  source = "../../"

  name                = "vm-adv-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D4s_v3"
  admin_username      = "azureadmin"
  admin_password      = "P@ssw0rd1234!"
  subnet_id           = azurerm_subnet.example.id
  availability_set_id = azurerm_availability_set.example.id
  create_public_ip    = true
  license_type        = "Windows_Server"
  timezone            = "Eastern Standard Time"
  identity_type       = "SystemAssigned"

  enable_boot_diagnostics = true

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
      disk_size_gb         = 128
      lun                  = 0
      caching              = "ReadOnly"
    }
    "logs" = {
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 64
      lun                  = 1
      caching              = "None"
    }
  }

  enable_antimalware_extension = true
  antimalware_settings = {
    real_time_protection_enabled = true
    scheduled_scan_enabled       = true
    scheduled_scan_type          = "Quick"
    scheduled_scan_day           = 7
    scheduled_scan_time          = 120
  }

  enable_monitoring_extension = true

  tags = {
    Environment = "staging"
    Project     = "example"
  }
}

output "vm_id" {
  value = module.windows_vm.vm_id
}

output "public_ip" {
  value = module.windows_vm.public_ip_address_value
}

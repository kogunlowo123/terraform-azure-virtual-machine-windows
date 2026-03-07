provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-vm-basic"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-vm-basic"
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

module "windows_vm" {
  source = "../../"

  name                = "vm-basic-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureadmin"
  admin_password      = "P@ssw0rd1234!"
  subnet_id           = azurerm_subnet.example.id

  tags = {
    Environment = "dev"
  }
}

output "vm_id" {
  value = module.windows_vm.vm_id
}

output "private_ip" {
  value = module.windows_vm.private_ip_address
}

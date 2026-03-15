resource "azurerm_resource_group" "test" {
  name     = "rg-windows-vm-test"
  location = "eastus2"
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-windows-vm-test"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "snet-windows-vm-test"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "test" {
  source = "../"

  name                = "vm-win-test01"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_username      = "azureadmin"
  admin_password      = "P@ssw0rd1234!Test"

  subnet_id = azurerm_subnet.test.id

  size = "Standard_D2s_v3"

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  identity_type = "SystemAssigned"

  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}

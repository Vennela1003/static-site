provider "azurerm" {
    features {}
}
resource "azurerm_resource_group" "staticrg" {
    name     = "example-resources"
    location = "East US"
}
 


resource "azurerm_virtual_network" "static_vnet" {
    name                = "example-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.staticrg.location
    resource_group_name = azurerm_resource_group.staticrg.name
}
 
resource "azurerm_subnet" "static_subnet" {
    name                 = "subnet1"
    resource_group_name  = azurerm_resource_group.staticrg.name
    virtual_network_name = azurerm_virtual_network.static_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_network_interface" "nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.staticrg.location
  resource_group_name = azurerm_resource_group.staticrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "static_vm" {
  name                = "example-win-vm"
  resource_group_name = azurerm_resource_group.staticrg.name
  location            = azurerm_resource_group.staticrg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "P@ssword1234"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
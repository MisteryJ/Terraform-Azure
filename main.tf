provider "azurerm" {
  features {}
  resource_provider_registrations = "none"  # use "register" if your role can register providers
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-cis-ws2025"
  location = "westus2"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "cis2025-vnet"
  address_space       = ["10.42.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "cis2025-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = ["104.34.42.175"]
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "cis2025-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "cis2025-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "cis_vm" {
  name                = "cis-ws2025-l2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"       # cost-effective lab size
  admin_username      = "azureuser"
  admin_password      = "P@ssword123!"
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "center-for-internet-security-inc"
    offer     = "cis-windows-server"
    sku       = "cis-windows-server2025-l2-gen2"
    version   = "latest"
  }

  plan {
    name      = "cis-windows-server2025-l2-gen2"
    product   = "cis-windows-server"
    publisher = "center-for-internet-security-inc"
  }

  enable_automatic_updates = false
  patch_mode               = "Manual"

  depends_on = [azurerm_marketplace_agreement.cis_terms]
}

output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}
741
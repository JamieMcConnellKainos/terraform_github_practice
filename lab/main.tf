# Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${random_pet.prefix.id}-rg"
}


# Virtual Network 1
resource "azurerm_virtual_network" "my_terraform_network_1" {
  name                = "${random_pet.prefix.id}-vnet-1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


# Virtual Network 2
resource "azurerm_virtual_network" "my_terraform_network_2" {
  name                = "${random_pet.prefix.id}-vnet-2"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


# Network Interface 1
resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_terraform_subnet_1.id
    private_ip_address_allocation = "Dynamic"
  }
}


# Network Interface 2
resource "azurerm_network_interface" "nic2" {
  name                = "nic2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_terraform_subnet_2.id
    private_ip_address_allocation = "Dynamic"
  }
}



resource "azurerm_virtual_machine" "vm1" {
  name                  = "vm1"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "vm2" {
  name                  = "vm2"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic2.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}


# Virtual Network Peering from VNet2 to VNet1
resource "azurerm_virtual_network_peering" "vnet2-to-vnet1" {
  name                         = "vnet2-to-vnet1"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.my_terraform_network_2.name
  remote_virtual_network_id    = azurerm_virtual_network.my_terraform_network_1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}


# Virtual Network Peering from VNet1 to VNet2
resource "azurerm_virtual_network_peering" "vnet1-to-vnet2" {
  name                         = "vnet1-to-vnet2"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.my_terraform_network_1.name
  remote_virtual_network_id    = azurerm_virtual_network.my_terraform_network_2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}


# Public IP 
resource "azurerm_public_ip" "example" {
  name                = "examplepip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


# Bastion Host
resource "azurerm_bastion_host" "example" {
  name                = "examplebastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.example.id
    public_ip_address_id = azurerm_public_ip.example.id
  }
}


# Bastion Subnet
resource "azurerm_subnet" "example" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network_1.name
  address_prefixes     = ["10.0.2.0/24"]
}


# Subnet 1
resource "azurerm_subnet" "my_terraform_subnet_1" {
  name                 = "subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network_1.name
  address_prefixes     = ["10.0.0.0/24"]
}


# Subnet 2
resource "azurerm_subnet" "my_terraform_subnet_2" {
  name                 = "subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network_2.name
  address_prefixes     = ["10.1.0.0/24"]
}


resource "random_pet" "prefix" {
  prefix = var.resource_group_name_prefix
  length = 1
}


# Network Security Group for VNet1
resource "azurerm_network_security_group" "nsg_vnet1" {
  name                = "nsg-vnet1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


# Inbound rule to allow traffic from VNet2 to VNet1
resource "azurerm_network_security_rule" "allow_vnet2_to_vnet1" {
  name                        = "allow-vnet2-to-vnet1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = tolist(azurerm_virtual_network.my_terraform_network_2.address_space)[0]
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg_vnet1.name
  resource_group_name         = azurerm_resource_group.rg.name
}


# Network Security Group for VNet2
resource "azurerm_network_security_group" "nsg_vnet2" {
  name                = "nsg-vnet2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


# Inbound rule to allow traffic from VNet1 to VNet2
resource "azurerm_network_security_rule" "allow_vnet1_to_vnet2" {
  name                        = "allow-vnet1-to-vnet2"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix = tolist(azurerm_virtual_network.my_terraform_network_1.address_space)[0]
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg_vnet2.name
  resource_group_name         = azurerm_resource_group.rg.name
}


# Associate NSG with Subnet1 in VNet1
resource "azurerm_subnet_network_security_group_association" "subnet1_nsg" {
  subnet_id                 = azurerm_subnet.my_terraform_subnet_1.id
  network_security_group_id = azurerm_network_security_group.nsg_vnet1.id
}


# Associate NSG with Subnet2 in VNet2
resource "azurerm_subnet_network_security_group_association" "subnet2_nsg" {
  subnet_id                 = azurerm_subnet.my_terraform_subnet_2.id
  network_security_group_id = azurerm_network_security_group.nsg_vnet2.id
}
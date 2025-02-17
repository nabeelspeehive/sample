# Specify the provider
provider "azurerm" {
  features {}
}

# Define Resource Group
resource "azurerm_resource_group" "example" {
  name     = "free-tier-resources"
  location = "East US"
}

# Define Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "free-tier-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Define Subnet
resource "azurerm_subnet" "example" {
  name                 = "free-tier-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define Public IP (Free Tier allows one free public IP)
resource "azurerm_public_ip" "example" {
  name                = "free-tier-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

# Define Network Interface
resource "azurerm_network_interface" "example" {
  name                = "free-tier-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "free-tier-ipconfig"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Define Virtual Machine
resource "azurerm_linux_virtual_machine" "example" {
  name                = "free-tier-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s" # Free Tier VM size
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.example.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30 # Within Free Tier
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Output the Public IP of the VM
output "vm_public_ip" {
  value = azurerm_public_ip.example.ip_address
}

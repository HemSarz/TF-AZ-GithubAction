## Resource Group
resource "azurerm_resource_group" "tfazrg" {
  name     = var.rgName
  location = var.location

}

## Storage Account
resource "azurerm_storage_account" "tfazstg" {
  name                     = var.StorageAccount
  resource_group_name      = azurerm_resource_group.tfazrg.name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}

resource "azurerm_storage_container" "tfazcont01" {
  name                 = var.STGContName
  storage_account_name = azurerm_storage_account.tfazstg.name
}

## KeyVault
resource "azurerm_key_vault" "tfazkv" {
  name                = var.kVName
  location            = var.location
  resource_group_name = azurerm_resource_group.tfazrg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name
}

## VNetwork

resource "azurerm_virtual_network" "tfazvnet" {
  name                = "vnet001"
  location            = var.location
  resource_group_name = azurerm_resource_group.tfazrg.name
  address_space       = ["10.0.0.0/16"]
}

##Subnet 

resource "azurerm_subnet" "sub01" {
  name                 = "app"
  resource_group_name  = azurerm_resource_group.tfazrg.name
  virtual_network_name = azurerm_virtual_network.tfazvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "sub02" {
  name                 = "web"
  resource_group_name  = azurerm_resource_group.tfazrg.name
  virtual_network_name = azurerm_virtual_network.tfazvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

## NIC PIP

resource "azurerm_public_ip" "tfazpip" {
  name                = "tfazpip"
  location            = var.location
  resource_group_name = azurerm_resource_group.tfazrg.name
  allocation_method   = "Dynamic"
}

##NIC
resource "azurerm_network_interface" "webintf" {
  name                = "webVmInt"
  location            = azurerm_resource_group.tfazrg.location
  resource_group_name = azurerm_resource_group.tfazrg.name

  ip_configuration {
    name                          = "webint01"
    subnet_id                     = azurerm_subnet.sub01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.99"
    public_ip_address_id          = azurerm_public_ip.tfazpip.id
  }
}


## NSG ssh

resource "azurerm_network_security_group" "sshAllow" {
  name                = "nsg-webintf-noreast-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.tfazrg.name

  security_rule {
    name                       = "ssh-tfazlnx-vm"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

##NSGAssociateNIC
resource "azurerm_subnet_network_security_group_association" "sshAllowAssoc" {
  subnet_id                 = azurerm_subnet.sub01.id
  network_security_group_id = azurerm_network_security_group.sshAllow.id
}

## VM
resource "azurerm_linux_virtual_machine" "web" {
  name                  = "webvm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.tfazrg.name
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.webintf.id]
  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_key_vault_secret.sshKey.value
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
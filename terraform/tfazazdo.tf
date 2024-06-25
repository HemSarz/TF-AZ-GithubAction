## Resource Group
resource "azurerm_resource_group" "tfazrg" {
  name     = "${var.prefix}-rg-${var.env}"
  location = var.location
}

## Storage Account

resource "random_string" "storage_account_name" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "tfazstg" {
  name                     = lower("${var.prefix}stg${var.env}${random_string.storage_account_name.result}")
  resource_group_name      = azurerm_resource_group.tfazrg.name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}

resource "azurerm_storage_container" "tfazcont-01" {
  name                 = "${var.prefix}-cont-${var.env}-01"
  storage_account_name = azurerm_storage_account.tfazstg.name
}

## KeyVault
resource "azurerm_key_vault" "tfazkv" {
  name                = "${var.prefix}-kv-${var.env}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.tfazrg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name
}

## Virtual Network
resource "azurerm_virtual_network" "tfazvnet" {
  name                = "${var.prefix}-vnet-${var.env}"
  location            = var.location
  resource_group_name = azurerm_resource_group.tfazrg.name
  address_space       = ["10.0.0.0/16"]
}

## Subnet
resource "azurerm_subnet" "sub-01" {
  name                 = "${var.prefix}-subnet-app-${var.env}"
  resource_group_name  = azurerm_resource_group.tfazrg.name
  virtual_network_name = azurerm_virtual_network.tfazvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

## NIC Public IP
resource "azurerm_public_ip" "tfazpip" {
  name                = "${var.prefix}-pip-${var.env}"
  location            = var.location
  resource_group_name = azurerm_resource_group.tfazrg.name
  allocation_method   = "Dynamic"
}

## Network Interface
resource "azurerm_network_interface" "webintf" {
  name                = "${var.prefix}-nic-web-${var.env}"
  location            = azurerm_resource_group.tfazrg.location
  resource_group_name = azurerm_resource_group.tfazrg.name

  ip_configuration {
    name                          = "${var.prefix}-ipconfig-web-${var.env}"
    subnet_id                     = azurerm_subnet.sub-01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.99"
    public_ip_address_id          = azurerm_public_ip.tfazpip.id
  }
}

## NSG for SSH
resource "azurerm_network_security_group" "sshAllow" {
  name                = "${var.prefix}-nsg-webintf-${var.env}"
  location            = var.location
  resource_group_name = azurerm_resource_group.tfazrg.name

  security_rule {
    name                       = "${var.prefix}-ssh-rule-${var.env}"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

## NSG Association
resource "azurerm_subnet_network_security_group_association" "sshAllowAssoc" {
  subnet_id                 = azurerm_subnet.sub-01.id
  network_security_group_id = azurerm_network_security_group.sshAllow.id
}

## Virtual Hub

resource "azurerm_virtual_hub" "hubtfaz" {
  name                = "${var.prefix}-hub-${var.env}"
  location            = azurerm_resource_group.tfazrg.location
  resource_group_name = azurerm_resource_group.tfazrg.name
}

## Virtual Machine
resource "azurerm_linux_virtual_machine" "web" {
  name                  = "${var.prefix}-vm-web-${var.env}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.tfazrg.name
  size                  = "Standard_F2"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.webintf.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = data.azurerm_key_vault_secret.sshKey.value
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_public_ip" "fwpip" {
  name                = "${var.prefix}-fwpip-${var.env}"
  location            = azurerm_resource_group.tfazrg.location
  resource_group_name = azurerm_resource_group.tfazrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_subnet" "fwsub" {
  name                 = "${var.prefix}-fwsub-${var.env}"
  resource_group_name  = azurerm_resource_group.tfazrg.name
  virtual_network_name = azurerm_virtual_network.tfazvnet.name
  address_prefixes     = ["10.1.10.0/24"]
}

resource "azurerm_firewall" "tfazfw" {
  name                = "${var.prefix}-fw01-${var.env}"
  location            = var.location
  resource_group_name = azurerm_resource_group.tfazrg.name
  sku_tier            = "Standard"
  sku_name            = "AZFW_VNet"

  ip_configuration {
    name                 = "${var.prefix}-fwipconfig-${var.env}"
    subnet_id            = azurerm_subnet.fwsub.id
    public_ip_address_id = azurerm_public_ip.fwpip.id
  }
}
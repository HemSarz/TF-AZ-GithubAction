provider "azurerm" {
  features {

  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = var.state_resource_group_name
    storage_account_name = var.state_storage_account_name
    container_name       = var.state_storage_account_container_name
    key                  = var.state_key_name
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.2"
    }
  }

}

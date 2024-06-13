provider "azurerm" {
  features {
    purge_soft_delete_on_destroy = true
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = var.state_resource_group_name
    storage_account_name = var.state_storage_account_name
    container_name       = "tfstatebcknd"
    key                  = "tfstatebcknd"
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.2"
    }
  }
}
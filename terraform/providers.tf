provider "azurerm" {
  features {

  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "tfaz-bcknd-rg"
    storage_account_name = "backndtfazstg"
    container_name       = "tfstatebckndcont"
    key                  = "tfstatebcknd"
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.2"
    }
  }

}

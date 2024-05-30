variable "prefix" {
  type    = string
  default = "tfaz"
}

variable "rgName" {
  type    = string
  default = "tfaz-rg"
}

variable "location" {
  type    = string
  default = "norwayeast"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "admin_username" {
  type    = string
  default = "adminuser"
}
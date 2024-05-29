# ResourceGroup VB
variable "rgName" {
  type    = string
  default = "tfazrg01"
}

variable "location" {
  type    = string
  default = "norwayeast"
}

#StorageAccount
variable "StorageAccount" {
  type    = string
  default = "tfazstg01"
}
variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "STGContName" {
  type    = string
  default = "tfazcont01"
}

## KeyVault
variable "kVName" {
  type    = string
  default = "tfazkv01"

}

variable "sku_name" {
  type    = string
  default = "standard"

}

#SPN
variable "SPNName" {
  type    = string
  default = "tfazspn"
}

variable "tenant_id" {
  type    = string
  default = "7afe75ee-20fb-4e79-93a6-9881f786e2d8"
}


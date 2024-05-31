data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "tfazrgbackend" {
  name = "tfaz-bcknd-rg"
}

data "azuread_service_principal" "tfazsp" {
  display_name = "tfazspnbcknd"
}

data "azurerm_key_vault" "bckndKV" {
  name                = "bcknd-tfaz-kv-01"
  resource_group_name = data.azurerm_resource_group.tfazrgbackend.name
}

data "azurerm_storage_account" "bckndstg" {
  name                = "backndtfazstg"
  resource_group_name = data.azurerm_resource_group.tfazrgbackend.name
}

#Fetch SSHKey
data "azurerm_key_vault_secret" "sshKey" {
  name         = "tfazlnxkeypub"
  key_vault_id = data.azurerm_key_vault.bckndKV.id

}

output "ssh_key" {
  value     = data.azurerm_key_vault_secret.sshKey.value
  sensitive = true
}
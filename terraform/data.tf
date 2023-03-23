data "azurerm_resource_group" "rg" {
  name = "rg-${var.project_name}${var.environment_suffix}"
}

data "azurerm_key_vault" "kv" {
  name                = "kv-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "database-name" {
  name         = "database-login"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "database-login" {
  name         = "database-login"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "database-password" {
  name         = "database-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "token-secret" {
  name         = "token-secret"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "refresh-token-secret" {
  name         = "refresh-token-secret"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "pgadmin-email" {
  name         = "pgadmin-email"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "pgadmin-password" {
  name         = "pgadmin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}
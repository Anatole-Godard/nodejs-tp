terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.48.0"
    }
  }

  backend "azurerm" {
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_postgresql_server" "sqlsvr" {
  name                = "sqlsvr-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  administrator_login          = data.azurerm_key_vault_secret.database-login.value
  administrator_login_password = data.azurerm_key_vault_secret.database-password.value

  sku_name              = "GP_Gen5_4"
  version               = "11"
  storage_mb            = 640000
  backup_retention_days = 7
  auto_grow_enabled     = true

  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"

}

resource "azurerm_postgresql_firewall_rule" "sql-srv" {
  name                = "fw-${var.project_name}${var.environment_suffix}"
  start_ip_address    = "40.112.8.12"
  end_ip_address      = "40.112.8.12"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.sqlsvr.name
}

resource "azurerm_postgresql_database" "database" {
  name                = "${data.azurerm_key_vault_secret.database-name.value}-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.sqlsvr.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

###############
# API Web App
###############
resource "azurerm_service_plan" "app-plan" {
  name                = "plan-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "web-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.app-plan.id

  site_config {
    application_stack {
      node_version = "16-lts"
    }
  }

  app_settings = {
    "PORT"                    = var.database_port,
    "DB_HOST"                 = azurerm_postgresql_server.sqlsvr.fqdn,
    "DB_DATABASE"             = azurerm_postgresql_database.database.name,
    "DB_USERNAME"             = "${data.azurerm_key_vault_secret.database-login.value}@${azurerm_postgresql_server.sqlsvr.name}"
    "DB_PASSWORD"             = data.azurerm_key_vault_secret.database-password.value,
    "ACCESS_TOKEN_SECRET"     = data.azurerm_key_vault_secret.token-secret.value,
    "REFRESH_TOKEN_SECRET"    = data.azurerm_key_vault_secret.refresh-token-secret.value,
    "DB_DAILECT"              = var.database_dialect,
    "DB_PORT"                 = var.database_port,
    ACCESS_TOKEN_EXPIRY       = var.access_token_expiry,
    REFRESH_TOKEN_EXPIRY      = var.refresh_token_expiry,
    REFRESH_TOKEN_COOKIE_NAME = var.refresh_token_cookie_name,
  }
}

resource "azurerm_container_group" "pgadmin" {
  location            = data.azurerm_resource_group.rg.location
  name                = "aci-pgadmin-${var.project_name}${var.environment_suffix}"
  os_type             = "Linux"
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_name_label      = "aci-pgadmin-${var.project_name}${var.environment_suffix}"

  container {
    image  = "dpage/pgadmin4"
    cpu    = "0.5"
    memory = "1.5"
    name   = "pgadmin"

    ports {
      port     = 1234
      protocol = "TCP"
    }

    environment_variables = {
      PGADMIN_DEFAULT_EMAIL    = data.azurerm_key_vault_secret.pgadmin-email.value
      PGADMIN_DEFAULT_PASSWORD = data.azurerm_key_vault_secret.pgadmin-password.value
    }
  }
}
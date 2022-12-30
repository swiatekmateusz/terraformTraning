provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "example" {
  name                     = "${var.prefix}storageacct"
  resource_group_name      = var.rgname
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "example" {
  name                = "${var.prefix}-appinsights"
  resource_group_name = var.rgname
  location            = var.location
  application_type    = "web"
}

resource "azurerm_service_plan" "example" {
  name                = "${var.prefix}-sp"
  location            = var.location
  resource_group_name = var.rgname
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "example" {
  name                = "${var.prefix}-LFA"
  location            = var.location
  resource_group_name = var.rgname
  service_plan_id     = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  site_config {
    application_insights_connection_string = azurerm_application_insights.example.connection_string
    application_stack {
      node_version = 18
    }
  }

  app_settings = {
    "db_server" = "${azurerm_mssql_server.example.name}.database.windows.net"
    "db_database" = azurerm_mssql_database.example.name
    "db_user" = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.example.name};SecretName=dbuser)"
    "db_password" = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.example.name};SecretName=dbpass)"
  }
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                        = "${var.prefix}akv"
  location                    = var.location
  resource_group_name         = var.rgname
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

data "azuread_service_principal" "app_sp" {
  display_name = azurerm_linux_function_app.example.name
  depends_on   = [
    azurerm_linux_function_app.example
  ]
}

resource "azurerm_key_vault_access_policy" "kv_read_access_policy" {
  key_vault_id = azurerm_key_vault.example.id

  tenant_id = data.azurerm_client_config.current.tenant_id  
  object_id = data.azuread_service_principal.app_sp.id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

resource "azurerm_key_vault_secret" "dbuser" {
  name         = "dbuser"
  value        = "${var.dbadmin}"
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_key_vault_secret" "dbpass" {
  name         = "dbpass"
  value        = "${var.dbadminpass}"
  key_vault_id = azurerm_key_vault.example.id
}
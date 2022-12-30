resource "azurerm_mssql_server" "example" {
  name                         = "${var.prefix}-sqlsvr"
  location                     = "${var.location}"
  resource_group_name          = "${var.rgname}"
  version                      = "12.0"
  administrator_login          = "${var.dbadmin}"
  administrator_login_password = "${var.dbadminpass}"
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "example" {
  name                          = "tododb"
  server_id                     = azurerm_mssql_server.example.id
  collation                     = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                   = 1
  min_capacity                  = 0.5
  read_scale                    = false
  sku_name                      = "GP_S_Gen5_1"
  zone_redundant                = false
  auto_pause_delay_in_minutes   = 60
}

resource "azurerm_mssql_firewall_rule" "example" {
  name                = "allow-azure-services"
  server_id           = azurerm_mssql_server.example.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
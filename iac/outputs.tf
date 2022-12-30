output "app_name" {
  value = azurerm_linux_function_app.example.name
}

output "server_name" {
  value = azurerm_mssql_server.example.name
}
resource "azurerm_static_site" "example" {
  name                = "${var.prefix}-SWA"
  location            = "${var.location}"
  resource_group_name = "${var.rgname}"
  sku_tier            = "Standard"
  sku_size            = "Standard"
}
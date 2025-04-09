data "azurerm_private_dns_zone" "existing_private_zone" {
  count               = local.fetch_zone_id ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

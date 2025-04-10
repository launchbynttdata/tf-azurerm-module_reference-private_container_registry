locals {
  acr_role_assignments = merge({
    acr_pull = {
      role_definition_name = "ACRPull"
      principal_id         = data.azurerm_client_config.current.object_id
    },
    acr_push = {
      role_definition_name = "ACRPush"
      principal_id         = data.azurerm_client_config.current.object_id
    }
  }, var.acr_role_assignments)
  location = var.region
  tags = merge(
    var.tags,
    {
      environment = var.environment
      region      = local.location
    }
  )
  generated_rg_name   = module.resource_names["rg"].dns_compliant_minimal_random_suffix
  generated_acr_name  = module.resource_names["acr"].minimal_random_suffix_without_any_separators
  generated_pesc_name = module.resource_names["private_endpoint_service_connection"].standard
  generated_vnet_name = module.resource_names["vnet"].minimal_random_suffix
}

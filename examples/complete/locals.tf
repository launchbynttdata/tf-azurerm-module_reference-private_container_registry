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
}

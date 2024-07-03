// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 1.0"

  for_each = var.resource_names_map

  logical_product_family  = var.product_family
  logical_product_service = var.product_service
  region                  = var.region
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  maximum_length          = each.value.max_length
  use_azure_region_abbr   = var.use_azure_region_abbr
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  count = var.create_resource_group ? 1 : 0

  name     = module.resource_names["rg"].standard
  location = var.region

  tags = merge(var.tags, { resource_name = module.resource_names["rg"].standard })
}

module "acr" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/container_registry/azurerm"
  version = "~> 1.0"

  container_registry_name       = var.container_registry_name != null ? var.container_registry_name : module.resource_names["acr"].lower_case_without_any_separators
  location                      = var.region
  resource_group_name           = var.create_resource_group ? module.resource_group[0].name : var.resource_group_name
  sku                           = "Premium"
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  identity_ids                  = var.identity_ids
  encryption                    = var.encryption
  network_rule_bypass_option    = var.network_rule_bypass_option
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  georeplications               = var.georeplications
  network_rule_set              = var.network_rule_set
  retention_policy              = var.retention_policy

  tags = merge(var.tags, { resource_name = module.resource_names["acr"].standard })

  depends_on = [module.resource_group]
}

module "private_dns_zone" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_zone/azurerm"
  version = "~> 1.0"

  zone_name           = var.private_dns_zone_name
  resource_group_name = var.create_resource_group ? module.resource_group[0].name : var.resource_group_name

  tags = var.tags

  depends_on = [module.resource_group]
}

module "vnet_link" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_vnet_link/azurerm"
  version = "~> 1.0"

  link_name             = "acr-pe-vnet-link"
  private_dns_zone_name = module.private_dns_zone.zone_name
  virtual_network_id    = local.vnet_id
  resource_group_name   = var.create_resource_group ? module.resource_group[0].name : var.resource_group_name

  tags = var.tags

  depends_on = [module.private_dns_zone, module.resource_group]
}

module "private_endpoint" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_endpoint/azurerm"
  version = "~> 1.0"

  region                          = var.region
  endpoint_name                   = module.resource_names["private_endpoint"].standard
  is_manual_connection            = false
  resource_group_name             = var.create_resource_group ? module.resource_group[0].name : var.resource_group_name
  private_service_connection_name = var.private_service_connection_name
  private_connection_resource_id  = module.acr.container_registry_id
  subresource_names               = ["registry"]
  subnet_id                       = var.acr_subnet_id
  private_dns_zone_ids            = [module.private_dns_zone.id]
  private_dns_zone_group_name     = var.private_dns_zone_group_name

  tags = var.tags

  depends_on = [module.resource_group, module.acr, module.private_dns_zone]
}

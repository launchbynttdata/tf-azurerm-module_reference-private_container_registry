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


###############################################################################
###
### Fixture infrastructure representing private DNS zone managed elsewhere
###
###############################################################################

module "dns_resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["dnsrg"].minimal_random_suffix
  location = local.location
  tags     = local.tags
}

module "dns_network" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm"
  version = "~> 2.0"

  use_for_each                                     = false
  vnet_location                                    = local.location
  address_space                                    = ["172.16.0.0/12"]
  bgp_community                                    = null
  ddos_protection_plan                             = null
  dns_servers                                      = []
  nsg_ids                                          = {}
  route_tables_ids                                 = {}
  subnet_delegation                                = {}
  subnet_private_endpoint_network_policies_enabled = {}
  subnet_names                                     = ["private-dns"]
  subnet_prefixes                                  = ["172.16.0.0/24"]
  subnet_service_endpoints                         = {}
  resource_group_name                              = module.resource_names["dnsrg"].minimal_random_suffix
  vnet_name                                        = module.resource_names["dnsvnet"].minimal_random_suffix
  tags                                             = local.tags
  depends_on                                       = [module.dns_resource_group]
}

module "private_dns_zone" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_zone/azurerm"
  version = "~> 1.0"

  zone_name           = var.private_dns_zone_name
  resource_group_name = module.resource_names["dnsrg"].minimal_random_suffix
  tags                = local.tags
}

module "private_dns_vnet_link" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_vnet_link/azurerm"
  version = "~> 1.0"

  link_name             = "tt_private_dns_vnet_link"
  private_dns_zone_name = var.private_dns_zone_name
  resource_group_name   = module.resource_names["dnsrg"].minimal_random_suffix
  virtual_network_id    = module.dns_network.vnet_id
  tags                  = local.tags
  depends_on            = [module.private_dns_zone]
}


###############################################################################
###
### Private ACR using alternate DNS zone
###
###############################################################################


module "container_registry" {
  source                               = "../.."
  acr_subnet_id                        = var.acr_subnet_id != null ? var.acr_subnet_id : lookup(module.network.vnet_subnets_name_id, "acr")
  resource_group_name                  = coalesce(var.resource_group_name, module.resource_names["rg"].minimal_random_suffix)
  create_resource_group                = false
  container_registry_name              = coalesce(var.container_registry_name, module.resource_names["acr"].minimal_random_suffix_without_any_separators)
  private_service_connection_name      = coalesce(var.private_service_connection_name, module.resource_names["private_endpoint_service_connection"].standard)
  network_rule_set                     = var.network_rule_set
  public_network_access_enabled        = var.public_network_access_enabled
  role_assignments                     = local.acr_role_assignments
  admin_enabled                        = var.admin_enabled
  retention_policy                     = var.retention_policy
  identity_ids                         = var.identity_ids
  encryption                           = var.encryption
  georeplications                      = var.georeplications
  network_rule_bypass_option           = var.network_rule_bypass_option
  zone_redundancy_enabled              = var.zone_redundancy_enabled
  private_dns_zone_name                = var.private_dns_zone_name
  private_dns_zone_group_name          = var.private_dns_zone_group_name
  create_dns_vnet_link                 = var.create_dns_vnet_link
  create_private_dns_zone              = var.create_private_dns_zone
  private_dns_zone_resource_group_name = coalesce(var.private_dns_zone_resource_group_name, module.resource_names["dnsrg"].minimal_random_suffix)

  tags       = var.tags
  depends_on = [module.dns_network, module.private_dns_zone, module.private_dns_vnet_link]
}

data "azurerm_client_config" "current" {
}

module "network" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm"
  version = "~> 2.0"

  use_for_each                                     = var.use_for_each
  vnet_location                                    = local.location
  address_space                                    = var.address_space
  bgp_community                                    = var.bgp_community
  ddos_protection_plan                             = var.ddos_protection_plan
  dns_servers                                      = var.dns_servers
  nsg_ids                                          = var.nsg_ids
  route_tables_ids                                 = var.route_tables_ids
  subnet_delegation                                = var.subnet_delegation
  subnet_private_endpoint_network_policies_enabled = var.subnet_private_endpoint_network_policies_enabled
  subnet_names                                     = var.subnet_names
  subnet_prefixes                                  = var.subnet_prefixes
  subnet_service_endpoints                         = var.subnet_service_endpoints
  resource_group_name                              = coalesce(var.resource_group_name, module.resource_names["rg"].minimal_random_suffix)
  vnet_name                                        = module.resource_names["vnet"].minimal_random_suffix
  tags                                             = local.tags

  depends_on = [module.resource_group]
}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 1.0"

  for_each = var.resource_names_map

  region                  = join("", split("-", local.location))
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  instance_resource       = var.resource_number
  maximum_length          = each.value.max_length
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  use_azure_region_abbr   = var.use_azure_region_abbr
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = coalesce(var.resource_group_name, module.resource_names["rg"].minimal_random_suffix)
  location = local.location
  tags     = local.tags
}

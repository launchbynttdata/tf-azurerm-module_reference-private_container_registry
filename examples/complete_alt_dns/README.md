# Complete with Alternate DNS Configuration

This example shows how to use this reference module to configure the private DNS entries into an existing Azure Private DNS zone in an alternate resource group and/or VNET.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.67 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns_resource_group"></a> [dns\_resource\_group](#module\_dns\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |
| <a name="module_dns_network"></a> [dns\_network](#module\_dns\_network) | terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm | ~> 2.0 |
| <a name="module_private_dns_zone"></a> [private\_dns\_zone](#module\_private\_dns\_zone) | terraform.registry.launch.nttdata.com/module_primitive/private_dns_zone/azurerm | ~> 1.0 |
| <a name="module_private_dns_vnet_link"></a> [private\_dns\_vnet\_link](#module\_private\_dns\_vnet\_link) | terraform.registry.launch.nttdata.com/module_primitive/private_dns_vnet_link/azurerm | ~> 1.0 |
| <a name="module_container_registry"></a> [container\_registry](#module\_container\_registry) | ../.. | n/a |
| <a name="module_network"></a> [network](#module\_network) | terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm | ~> 2.0 |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 1.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family for which the resource is created. Example: org\_name, department\_name. | `string` | `"dso"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service for which the resource is created. For example, backend, frontend, middleware etc. | `string` | `"acr"` | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"eastus"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object(<br>    {<br>      name       = string<br>      max_length = optional(number, 60)<br>    }<br>  ))</pre> | <pre>{<br>  "acr": {<br>    "max_length": 60,<br>    "name": "acr"<br>  },<br>  "dnsrg": {<br>    "max_length": 60,<br>    "name": "dnsrg"<br>  },<br>  "dnsvnet": {<br>    "max_length": 80,<br>    "name": "dnsvnet"<br>  },<br>  "private_dns_zone_link": {<br>    "max_length": 80,<br>    "name": "pdzl"<br>  },<br>  "private_endpoint": {<br>    "max_length": 60,<br>    "name": "pe"<br>  },<br>  "private_endpoint_service_connection": {<br>    "max_length": 80,<br>    "name": "pesc"<br>  },<br>  "resource_group_vnet": {<br>    "max_length": 80,<br>    "name": "vnetrg"<br>  },<br>  "rg": {<br>    "max_length": 60,<br>    "name": "rg"<br>  },<br>  "vnet": {<br>    "max_length": 60,<br>    "name": "vnet"<br>  }<br>}</pre> | no |
| <a name="input_use_azure_region_abbr"></a> [use\_azure\_region\_abbr](#input\_use\_azure\_region\_abbr) | Whether to use Azure region abbreviation for azure region | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group in which the ACR will be created. If not provided, this module will create one | `string` | `null` | no |
| <a name="input_container_registry_name"></a> [container\_registry\_name](#input\_container\_registry\_name) | Container Registry name. If provided, then the name generated by the naming module won't be used | `string` | `null` | no |
| <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled) | Specifies whether the admin user is enabled. Defaults to true. When enabled, password tokens are generated to be used with docker login | `bool` | `false` | no |
| <a name="input_retention_policy"></a> [retention\_policy](#input\_retention\_policy) | Set a retention policy for untagged manifests | <pre>object({<br>    days    = optional(number)<br>    enabled = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned.<br>    This is required when `type` is set to `UserAssigned` or `SystemAssigned, UserAssigned` | `list(string)` | `null` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Encrypt registry using a customer-managed key | <pre>object({<br>    key_vault_key_id   = string<br>    identity_client_id = string<br>  })</pre> | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed for the container registry. Defaults to true. | `bool` | `true` | no |
| <a name="input_network_rule_bypass_option"></a> [network\_rule\_bypass\_option](#input\_network\_rule\_bypass\_option) | Whether to allow trusted Azure services to access a network restricted Container Registry? Possible values are<br>    None and AzureServices. Defaults to AzureServices | `string` | `"AzureServices"` | no |
| <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled) | Whether zone redundancy is enabled for this Container Registry? Changing this forces a new resource to be created.<br>    Defaults to false | `bool` | `false` | no |
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | If specified, the ACR will be replicated to other regions specified in this block | <pre>map(object({<br>    location                  = string<br>    regional_endpoint_enabled = bool<br>    zone_redundancy_enabled   = bool<br>  }))</pre> | `{}` | no |
| <a name="input_network_rule_set"></a> [network\_rule\_set](#input\_network\_rule\_set) | Network rules to explicitly allow IP ranges<br>    CIDR ranges should be provided | `list(string)` | `[]` | no |
| <a name="input_acr_subnet_id"></a> [acr\_subnet\_id](#input\_acr\_subnet\_id) | The ID of the subnet in which the private endpoint should be created. | `string` | `null` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | The name of the private DNS zone to which the private endpoint should be associated. Defaults to privatelink.azurecr.io, but needs to change for gov cloud. | `string` | `"privatelink.azurecr.io"` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | The name of the private service connection. Defaults to pvt-connection-acr | `string` | `"pvt-connection-acr"` | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | The name of the private DNS zone group. Defaults to pvt-dns-group | `string` | `"pvt-dns-group"` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | The name of the resource group in which the private DNS zone is created. Defaults to null. | `string` | `null` | no |
| <a name="input_acr_role_assignments"></a> [acr\_role\_assignments](#input\_acr\_role\_assignments) | A map of role assignments to be created for the container registry | <pre>map(object({<br>    role_definition_name = string<br>    principal_id         = string<br>  }))</pre> | `{}` | no |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Name of the private dns zone. For public cloud, the default value is `privatelink.azurecr.io` and for sovereign clouds, the default value is `privatelink.azurecr.us` | `string` | `"privatelink.azurecr.io"` | no |
| <a name="input_create_private_dns_zone"></a> [create\_private\_dns\_zone](#input\_create\_private\_dns\_zone) | Whether to create a private DNS zone. Defaults to true. | `bool` | `true` | no |
| <a name="input_create_dns_vnet_link"></a> [create\_dns\_vnet\_link](#input\_create\_dns\_vnet\_link) | Whether to create a VNet link for the private DNS zone. Defaults to true. | `bool` | `true` | no |
| <a name="input_use_for_each"></a> [use\_for\_each](#input\_use\_for\_each) | Use `for_each` instead of `count` to create multiple resource instances. | `bool` | `false` | no |
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used by the virtual network. | `list(string)` | n/a | yes |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | (Optional) The BGP community attribute in format `<as-number>:<community-value>`. | `string` | `null` | no |
| <a name="input_ddos_protection_plan"></a> [ddos\_protection\_plan](#input\_ddos\_protection\_plan) | The set of DDoS protection plan configuration | <pre>object({<br>    enable = bool<br>    id     = string<br>  })</pre> | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to be used with vNet. | `list(string)` | `[]` | no |
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids) | A map of subnet name to Network Security Group IDs | `map(string)` | `{}` | no |
| <a name="input_route_tables_ids"></a> [route\_tables\_ids](#input\_route\_tables\_ids) | A map of subnet name to Route table ids | `map(string)` | `{}` | no |
| <a name="input_subnet_delegation"></a> [subnet\_delegation](#input\_subnet\_delegation) | A map of subnet name to delegation block on the subnet | `map(map(any))` | `{}` | no |
| <a name="input_subnet_private_endpoint_network_policies_enabled"></a> [subnet\_private\_endpoint\_network\_policies\_enabled](#input\_subnet\_private\_endpoint\_network\_policies\_enabled) | A map of subnet name to enable/disable private link service network policies on the subnet. | `map(string)` | `{}` | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | A list of public subnets inside the vNet. | `list(string)` | n/a | yes |
| <a name="input_subnet_prefixes"></a> [subnet\_prefixes](#input\_subnet\_prefixes) | The address prefix to use for the subnet. | `list(string)` | n/a | yes |
| <a name="input_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#input\_subnet\_service\_endpoints) | A map of subnet name to service endpoints to add to the subnet. | `map(any)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be associated with the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_registry_name"></a> [container\_registry\_name](#output\_container\_registry\_name) | The URL of the Azure Container Registry |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group |
| <a name="output_ext_dns_resource_group_name"></a> [ext\_dns\_resource\_group\_name](#output\_ext\_dns\_resource\_group\_name) | The name of the external DNS Resource Group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

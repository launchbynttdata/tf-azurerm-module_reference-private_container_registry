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

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = var.create_resource_group ? module.resource_group[0].name : var.resource_group_name
}

output "resource_group_id" {
  description = "The ID of the Resource Group"
  value       = try(module.resource_group.id, "")
}

output "container_registry_id" {
  description = "The ID of the Container Registry"
  value       = module.acr.container_registry_id
}

output "container_registry_login_server" {
  description = "The login server of the Container Registry"
  value       = module.acr.container_registry_login_server
}

output "container_registry_name" {
  description = "Name of the Container Registry"
  value       = module.acr.container_registry_name
}

output "container_registry_admin_username" {
  description = "The admin username of the Container Registry"
  value       = module.acr.container_registry_admin_username
  sensitive   = true
}

output "container_registry_admin_password" {
  description = "The admin password of the Container Registry"
  value       = module.acr.container_registry_admin_password
  sensitive   = true
}

output "container_registry_admin_enabled" {
  description = "The admin enable of the Container Registry"
  value       = module.acr.container_registry_admin_enabled
  sensitive   = true
}

output "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone"
  value       = module.private_dns_zone.id
}

output "private_dns_zone_name" {
  description = "The name of the Private DNS Zone"
  value       = module.private_dns_zone.zone_name
}

output "vnet_link_id" {
  description = "The ID of the VNet Link"
  value       = module.vnet_link.id
}

output "private_endpoint_id" {
  description = "The ID of the Private Endpoint"
  value       = module.private_endpoint.id
}

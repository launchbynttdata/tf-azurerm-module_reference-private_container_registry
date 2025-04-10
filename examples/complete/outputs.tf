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

output "container_registry_name" {
  description = "The URL of the Azure Container Registry"
  value       = module.container_registry.container_registry_name
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = coalesce(var.resource_group_name, local.generated_rg_name)
}

// empty.
address_space                 = ["10.9.0.0/16"]
subnet_names                  = ["acr"]
subnet_prefixes               = ["10.9.1.0/24"]
network_rule_set              = []
public_network_access_enabled = true # must be true to allow tests to work
create_dns_vnet_link          = false
create_private_dns_zone       = false

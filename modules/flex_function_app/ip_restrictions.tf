locals {
  ip_restriction = {
    "defaultDenyAll" = {
      name        = "DefaultDeny"
      action      = "Deny"
      description = "Default deny to block any incoming traffic."
      ip_address  = "0.0.0.0/0"
      priority    = 65001
    }
  }
  my_ips = { for rule in var.allowed_ips_to_access : "rule${index(var.allowed_ips_to_access, rule)}" => {
    name        = "rule${index(var.allowed_ips_to_access, rule)}"
    action      = "Allow"
    description = "Allowed ip to call the azure function."
    priority    = 65000
    ip_address  = rule
  } }
}

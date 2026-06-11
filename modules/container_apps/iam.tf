
# resource "azurerm_role_assignment" "iam" {
#   for_each             = { for role in var.iam_roles : "${role.role_name}-${role.scope}" => role }
#   scope                = each.value.scope
#   principal_type       = "ServicePrincipal"
#   principal_id         = azurerm_container_app.this.identity[0].principal_id
#   role_definition_name = each.value.role_name
# }
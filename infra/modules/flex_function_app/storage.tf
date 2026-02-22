

resource "azurerm_storage_account" "this" {
  name                = var.storage_account_name == null ? "stg${var.function_app_name}" : var.storage_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled     = true
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  allowed_copy_scope                = "AAD"
  cross_tenant_replication_enabled  = false
  default_to_oauth_authentication   = true
  shared_access_key_enabled         = false
  infrastructure_encryption_enabled = true
}

resource "azurerm_storage_container" "this" {
  name                  = "${var.function_app_name}-code"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}


# resource "azurerm_storage_account_network_rules" "this" {
#   ip_rules           = concat(
#     azurerm_function_app_flex_consumption.this.outbound_ip_address_list,
#     var.allowed_ips_to_access
#   )
#   default_action     = "Deny"
#   bypass             = ["AzureServices"]
#   storage_account_id = azurerm_storage_account.this.id
# }


resource "azurerm_role_assignment" "storage_access" {
  for_each = { for role in [
    "Storage Blob Data Contributor",
    "Storage Table Data Contributor",
    "Storage Queue Data Contributor"
  ] : role => role }
  scope                = azurerm_storage_account.this.id
  principal_id         = azurerm_function_app_flex_consumption.this.identity[0].principal_id
  principal_type       = "ServicePrincipal"
  role_definition_name = each.value
  depends_on           = [azurerm_function_app_flex_consumption.this]
}

data "azurerm_client_config" "current" {}

locals {
  current_user_object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "admin_access" {
  scope                = azurerm_storage_account.this.id
  principal_id         = local.current_user_object_id
  role_definition_name = "Storage Blob Data Contributor"
  depends_on           = [azurerm_function_app_flex_consumption.this]
}



resource "azurerm_api_management_identity_provider_aad" "this" {
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name

  client_id       = azuread_application.this["portal-auth"].client_id
  client_secret   = azuread_application_password.this["portal-auth"].value
  allowed_tenants = [data.azuread_client_config.this.tenant_id]
  client_library  = "MSAL-2"

}
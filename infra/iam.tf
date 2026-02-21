data "azurerm_client_config" "this" {}

data "azuread_client_config" "this" {}

data "azuread_directory_object" "this" {
  object_id = data.azuread_client_config.this.object_id
}

data "azuread_user" "this" {
  count     = data.azuread_directory_object.this.type == "User" ? 1 : 0
  object_id = data.azurerm_client_config.this.object_id
}

data "azuread_application" "this" {
  count     = data.azuread_directory_object.this.type == "ServicePrincipal" ? 1 : 0
  object_id = data.azurerm_client_config.this.object_id
}

resource "azurerm_role_assignment" "this" {
  scope                = module.ai_foundry.id
  principal_id         = data.azuread_client_config.this.object_id
  role_definition_name = "Azure AI User"
  principal_type       = data.azuread_directory_object.this.type
}
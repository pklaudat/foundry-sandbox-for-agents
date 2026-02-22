data "azuread_client_config" "this" {}

locals {
  apps = {
    "api-auth" = {
      app_role = {
        allowed_member_types = ["Application", "User"]
        description          = "Role to access api management"
        display_name         = "APIM.Access"
        value                = "APIM.Access"
        id                   = random_uuid.this.result
      }
    }
    "portal-auth" = {
      optional_claims = {
        id_token = ["email", "family_name", "given_name"]
      }
      web = {
        redirect_uris = ["${azurerm_api_management.this.gateway_url}/signin"]
      }
    }
  }
  role_assignments = {
    for app_name, app in local.apps :
    app_name => app
    if contains(keys(app), "app_role")
  }
}

resource "random_uuid" "this" {
  keepers = {
    name     = var.name
    location = var.location
  }
}


resource "azuread_application" "this" {
  for_each     = local.apps
  display_name = lower("${azurerm_api_management.this.name}-${each.key}")

  #   web {
  #     redirect_uris = [
  #       "https://${azurerm_api_management.this.gateway_url}/signin-oauth/code/callback"
  #     ]
  #   }

  owners = [data.azuread_client_config.this.object_id]

  dynamic "app_role" {
    for_each = try([each.value.app_role], [])
    content {
      allowed_member_types = app_role.value.allowed_member_types
      description          = app_role.value.description
      display_name         = app_role.value.display_name
      value                = app_role.value.value
      id                   = app_role.value.id
    }
  }

  api {
    requested_access_token_version = 2
  }

  dynamic "optional_claims" {
    for_each = try([each.value.optional_claims], [])
    content {
      dynamic "id_token" {
        for_each = toset(try(optional_claims.value.id_token, []))
        content {
          name = id_token.value
          # additional_properties = id_token.value.additional_properties
        }
      }
    }

  }

  # required_resource_access {
  #   resource_app_id = " "
  #   resource_access {
  #     id = random_uuid.this[local.apps].result
  #     type = "User"
  #   }
  # }
}


resource "azuread_application_password" "this" {
  for_each       = local.apps
  application_id = azuread_application.this[each.key].id
}

resource "azuread_service_principal" "this" {
  for_each                     = local.apps
  client_id                    = azuread_application.this[each.key].client_id
  owners                       = [data.azuread_client_config.this.object_id]
  app_role_assignment_required = true
  depends_on                   = [azuread_application.this]
}

resource "azuread_app_role_assignment" "this" {
  for_each            = local.role_assignments
  app_role_id         = each.value.app_role.id
  resource_object_id  = azuread_service_principal.this[each.key].object_id
  principal_object_id = data.azuread_client_config.this.object_id
  depends_on          = [azuread_application.this, azuread_service_principal.this]
}


resource "azurerm_api_management_authorization_server" "entra_auth" {
  name                = "entra-oauth"
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name

  display_name = "Entra ID OAuth"
  description  = "OAuth2 Authorization Server using Microsoft Entra ID"

  client_id     = azuread_application.this["api-auth"].client_id
  client_secret = azuread_application_password.this["api-auth"].value

  client_registration_endpoint = "http://localhost"
  authorization_methods        = ["GET"]

  authorization_endpoint = "https://login.microsoftonline.com/${data.azuread_client_config.this.tenant_id}/oauth2/v2.0/authorize"
  token_endpoint         = "https://login.microsoftonline.com/${data.azuread_client_config.this.tenant_id}/oauth2/v2.0/token"

  default_scope = "api://${azuread_application.this["api-auth"].client_id}/api.read"

  grant_types = [
    "authorizationCode",
    "clientCredentials"
  ]

  bearer_token_sending_methods = [
    "authorizationHeader"
  ]
}
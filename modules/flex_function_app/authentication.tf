data "azuread_client_config" "this" {}

resource "azuread_application" "this" {
  display_name = lower("${var.function_app_name}-auth")
  owners       = [data.azuread_client_config.this.object_id]

  web {
    redirect_uris = ["https://${var.function_app_name}.azurewebsites.net/.auth/login/aad/callback"]
    implicit_grant {
      id_token_issuance_enabled = true
    }
  }

  api {
    requested_access_token_version = 2
  }

  optional_claims {
    id_token {
      name = "email"
    }
  }
}

resource "azuread_application_password" "this" {
  application_id = azuread_application.this.id
}

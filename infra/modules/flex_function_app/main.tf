locals {
  base_app_settings = {
    "AzureWebJobsStorage__accountName"     = azurerm_storage_account.this.name
    "AzureWebJobsStorage__blobServiceUri"  = trimsuffix(azurerm_storage_account.this.primary_blob_endpoint, "/")
    "AzureWebJobsStorage__queueServiceUri" = trimsuffix(azurerm_storage_account.this.primary_queue_endpoint, "/")
    "AzureWebJobsStorage__tableServiceUri" = trimsuffix(azurerm_storage_account.this.primary_table_endpoint, "/")
    "AzureWebJobsStorage__credential"      = "managedidentity"
  }
  monitoring_app_settings = var.monitoring_enabled ? {
    "APPLICATIONINSIGHTS_AUTHENTICATION_STRING" = "Authorization=AAD"
  } : {}

  app_registration_settings = {
    replace("${var.function_app_name}__credential", "-", "_") = azuread_application_password.this.value
  }

}

resource "azurerm_service_plan" "this" {
  count               = var.service_plan_id == null ? 1 : 0
  name                = "${var.function_app_name}-asp"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "FC1"
  os_type             = "Linux"
}


resource "azurerm_function_app_flex_consumption" "this" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  identity {
    type         = "SystemAssigned"
    identity_ids = []
  }
  service_plan_id             = var.service_plan_id == null ? azurerm_service_plan.this[0].id : var.service_plan_id
  storage_authentication_type = "SystemAssignedIdentity"
  storage_container_endpoint  = "${azurerm_storage_account.this.primary_blob_endpoint}${azurerm_storage_container.this.name}"
  storage_container_type      = "blobContainer"
  runtime_name                = var.runtime_name
  runtime_version             = var.runtime_name == "python" ? var.runtime_version : "1.0"
  maximum_instance_count      = 40
  instance_memory_in_mb       = 2048
  webdeploy_publish_basic_authentication_enabled = false
  https_only = true

  app_settings = merge(
    local.base_app_settings,
    local.monitoring_app_settings,
    var.app_settings,
    local.app_registration_settings
  )

  auth_settings_v2 {
    auth_enabled = true
    require_authentication = true
    unauthenticated_action = "RedirectToLoginPage"

    login {
      token_store_enabled = true
    }

    default_provider = "azureactivedirectory"

    active_directory_v2 {
      client_id                  = azuread_application.this.client_id
      client_secret_setting_name = keys(local.app_registration_settings)[0]
      allowed_identities         = [data.azuread_client_config.this.object_id]
      tenant_auth_endpoint       = "https://login.microsoftonline.com/${data.azuread_client_config.this.tenant_id}/v2.0"
    }

  }
  site_config {
    application_insights_connection_string = var.monitoring_enabled ? var.app_insights_connection_string : null
    application_insights_key               = var.monitoring_enabled ? var.app_insights_instrumentation_key : null


    dynamic "ip_restriction" {
      for_each = merge(local.ip_restriction, local.my_ips)
      content {
        name        = ip_restriction.value.name
        description = ip_restriction.value.description
        ip_address  = ip_restriction.value.ip_address
        action      = ip_restriction.value.action
        priority    = ip_restriction.value.priority
      }

    }
  }
}


resource "azurerm_api_management" "this" {
  name                = var.name
  location            = var.location
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  virtual_network_type          = "None"
  public_network_access_enabled = true
  dynamic "additional_location" {
    for_each = { for location in var.additional_locations : location => location }
    content {
      location = each.value
    }
  }

  sign_in {
    enabled = true
  }


}

output "id" {
  description = "the api management resource id."
  value       = azurerm_api_management.this.id
}

output "gateway_url" {
  description = "the api management gatewat url."
  value       = azurerm_api_management.this.gateway_url
}

output "management_url" {
  description = "the api management url."
  value       = azurerm_api_management.this.management_api_url
}

output "portal_url" {
  description = "the api management portal ur."
  value       = azurerm_api_management.this.portal_url
}
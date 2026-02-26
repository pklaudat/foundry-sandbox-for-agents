

locals {
  baseline_tags = {
    managed_by  = "Terraform"
    environment = var.environment
    created_by  = data.azuread_directory_object.this.type == "User" ? data.azuread_user.this[0].display_name : data.azuread_application.this[0].display_name
  }

}

resource "random_string" "this" {
  special = false
  length  = 4
  lower   = true
  upper   = false
  keepers = {
    prefix   = var.prefix_name
    location = var.location
  }
}

data "http" "my_public_ip" {
  url = "https://api.ipify.org"
}

resource "azurerm_resource_group" "this" {
  name     = "RG_AI_FOUNDRY_${upper(var.prefix_name)}_${upper(var.environment)}_${upper(var.location)}"
  location = var.location
  tags     = merge(local.baseline_tags, var.tags)
}

module "ai_foundry" {
  source                = "./modules/ai_foundry"
  depends_on            = [azurerm_resource_group.this]
  name                  = "foundry-${lower(var.prefix_name)}-${var.environment}-${random_string.this.result}"
  resource_group_id     = azurerm_resource_group.this.id
  location              = var.location
  allowed_ips_to_access = [chomp(data.http.my_public_ip.response_body)]
  allowed_egress_fqdns  = var.allowed_fqdn_ai_services
  models                = var.models
}


module "mcp_servers" {
  for_each = { for mcp in var.serverless_mcp_servers: mcp.name => mcp }
  source = "./modules/flex_function_app"
  depends_on = [ azurerm_resource_group.this ]
  function_app_name = each.key
  resource_group_name = azurerm_resource_group.this.name
  location = var.location
}
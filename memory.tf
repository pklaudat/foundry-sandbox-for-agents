


module "agent_memory" {
  source                       = "./modules/cosmos_db"
  cosmos_db_account_name       = var.cosmos_db_account_name
  resource_group_name          = azurerm_resource_group.this["ai_instances"].name
  location                     = var.location
  free_tier_enabled            = false
  readonly_access_principal_id = null
  databases_config             = var.databases
  ip_range_filter              = [trim(data.http.my_public_ip.response_body, " ")]
  capabilities = []

  depends_on = [azurerm_resource_group.this]

}


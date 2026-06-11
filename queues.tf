

module "servicebus" {
    count = length(var.queues) > 0 ?  1 : 0
  source                    = "./modules/servicebus"
  resource_group_name       = azurerm_resource_group.this["ai_instances"].name
  servicebus_namespace_name = "sb-${var.prefix_name}-${var.location}"
  queues                    = var.queues
  location                  = var.location
}
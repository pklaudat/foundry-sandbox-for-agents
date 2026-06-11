resource "azurerm_servicebus_namespace" "this" {
  name                = var.servicebus_namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = var.sku
}

resource "azurerm_servicebus_queue" "this" {
  for_each = {
    for queue in var.queues : queue.name => queue
  }

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes                = each.value.max_size_in_megabytes
  default_message_ttl                  = each.value.default_message_ttl
  lock_duration                        = each.value.lock_duration
  max_delivery_count                   = each.value.max_delivery_count
  dead_lettering_on_message_expiration = each.value.dead_lettering_on_message_expiration
}

resource "azurerm_container_app_environment" "this" {
  name                = var.app_environment_name
  resource_group_name = var.resource_group_name
  location            = var.location

  public_network_access = "Enabled"
}


resource "azurerm_container_app" "this" {
  for_each            = { for t in var.templates : t.app_name => t }
  name                = each.key
  resource_group_name = var.resource_group_name

  depends_on                   = [azurerm_container_app_environment.this]
  container_app_environment_id = azurerm_container_app_environment.this.id
  identity {
    type = "SystemAssigned"
  }

  template {
    dynamic "container" {
      for_each = { for container in each.value.containers : "${each.value.app_name}-${container.name}" => container }
      content {
        name   = container.value.name
        cpu    = container.value.cpu
        memory = container.value.memory
        image  = container.value.image
      }

    }

    max_replicas = each.value.max_replicas
    min_replicas = each.value.min_replicas

  }

  revision_mode = "Multiple"

}
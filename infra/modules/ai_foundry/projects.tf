


resource "azapi_resource" "project" {
  for_each   = toset(var.projects)
  type       = "Microsoft.CognitiveServices/accounts/projects@2025-10-01-preview"
  depends_on = [azapi_resource.this]
  name       = each.key
  parent_id  = azapi_resource.this.id
  location   = var.location
  identity {
    type         = "SystemAssigned"
    identity_ids = []
  }

  body = {
    properties = {
      displayName = "Project ${each.key}"
      description = "AI Foundry Project for ${each.key}"
    }
  }

  response_export_values = ["*"]

}
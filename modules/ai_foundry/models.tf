

resource "azapi_resource" "models" {
  for_each             = { for model in var.models : model.deployment_name => model }
  type                 = "Microsoft.CognitiveServices/accounts/deployments@2025-10-01-preview"
  name                 = each.key
  parent_id            = azapi_resource.this.id
  ignore_null_property = true
  body = {
    sku = {
      name     = each.value.sku.name
      capacity = each.value.sku.capacity
      family   = each.value.sku.family
    }
    properties = {
      model = {
        format    = each.value.model.format
        name      = each.value.model.name
        publisher = each.value.model.publisher
        source    = each.value.model.source
        version   = each.value.model.version
      }
      versionUpgradeOption = each.value.version_upgrade_option
      raiPolicyName        = each.value.rai_policy_name
    }
  }
  depends_on = [azapi_resource.this]
}